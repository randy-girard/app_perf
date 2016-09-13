require "i18n"

module Groupdate
  class Magic
    def relation(column, relation)
      if relation.default_timezone == :local
        raise "ActiveRecord::Base.default_timezone must be :utc to use Groupdate"
      end

      time_zone = self.time_zone.tzinfo.name

      adapter_name = relation.connection.adapter_name
      query =
        case adapter_name
        when "MySQL", "Mysql2", "Mysql2Spatial"
          case field
          when :day_of_week # Sunday = 0, Monday = 1, etc
            # use CONCAT for consistent return type (String)
            ["DAYOFWEEK(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?)) - 1", time_zone]
          when :hour_of_day
            ["(EXTRACT(HOUR from CONVERT_TZ(#{column}, '+00:00', ?)) + 24 - #{day_start / 3600}) % 24", time_zone]
          when :day_of_month
            ["DAYOFMONTH(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?))", time_zone]
          when :month_of_year
            ["MONTH(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?))", time_zone]
          when :week
            ["CONVERT_TZ(DATE_FORMAT(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL ((#{7 - week_start} + WEEKDAY(CONVERT_TZ(#{column}, '+00:00', ?) - INTERVAL #{day_start} second)) % 7) DAY) - INTERVAL #{day_start} second, '+00:00', ?), '%Y-%m-%d 00:00:00') + INTERVAL #{day_start} second, ?, '+00:00')", time_zone, time_zone, time_zone]
          when :quarter
            ["DATE_ADD(CONVERT_TZ(DATE_FORMAT(DATE(CONCAT(EXTRACT(YEAR FROM CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?)), '-', LPAD(1 + 3 * (QUARTER(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?)) - 1), 2, '00'), '-01')), '%Y-%m-%d %H:%i:%S'), ?, '+00:00'), INTERVAL #{day_start} second)", time_zone, time_zone, time_zone]
          else
            format =
              case field
              when :second
                "%Y-%m-%d %H:%i:%S"
              when :minute
                "%Y-%m-%d %H:%i:00"
              when :hour
                "%Y-%m-%d %H:00:00"
              when :day
                "%Y-%m-%d 00:00:00"
              when :month
                "%Y-%m-01 00:00:00"
              else # year
                "%Y-01-01 00:00:00"
              end

            ["DATE_ADD(CONVERT_TZ(DATE_FORMAT(CONVERT_TZ(DATE_SUB(#{column}, INTERVAL #{day_start} second), '+00:00', ?), '#{format}'), ?, '+00:00'), INTERVAL #{day_start} second)", time_zone, time_zone]
          end
        when "PostgreSQL", "PostGIS"
          case field
          when :day_of_week
            ["EXTRACT(DOW from #{column}::timestamptz AT TIME ZONE ? - INTERVAL '#{day_start} second')::integer", time_zone]
          when :hour_of_day
            ["EXTRACT(HOUR from #{column}::timestamptz AT TIME ZONE ? - INTERVAL '#{day_start} second')::integer", time_zone]
          when :day_of_month
            ["EXTRACT(DAY from #{column}::timestamptz AT TIME ZONE ? - INTERVAL '#{day_start} second')::integer", time_zone]
          when :month_of_year
            ["EXTRACT(MONTH from #{column}::timestamptz AT TIME ZONE ? - INTERVAL '#{day_start} second')::integer", time_zone]
          when :week # start on Sunday, not PostgreSQL default Monday
            ["(DATE_TRUNC('#{field}', (#{column}::timestamptz - INTERVAL '#{week_start} day' - INTERVAL '#{day_start} second') AT TIME ZONE ?) + INTERVAL '#{week_start} day' + INTERVAL '#{day_start} second') AT TIME ZONE ?", time_zone, time_zone]
          else
            ["(DATE_TRUNC('#{field}', (#{column}::timestamptz - INTERVAL '#{day_start} second') AT TIME ZONE ?) + INTERVAL '#{day_start} second') AT TIME ZONE ?", time_zone, time_zone]
          end
        when "Redshift"
          case field
          when :day_of_week # Sunday = 0, Monday = 1, etc.
            ["EXTRACT(DOW from CONVERT_TIMEZONE(?, #{column}::timestamp) - INTERVAL '#{day_start} second')::integer", time_zone]
          when :hour_of_day
            ["EXTRACT(HOUR from CONVERT_TIMEZONE(?, #{column}::timestamp) - INTERVAL '#{day_start} second')::integer", time_zone]
          when :day_of_month
            ["EXTRACT(DAY from CONVERT_TIMEZONE(?, #{column}::timestamp) - INTERVAL '#{day_start} second')::integer", time_zone]
          when :month_of_year
            ["EXTRACT(MONTH from CONVERT_TIMEZONE(?, #{column}::timestamp) - INTERVAL '#{day_start} second')::integer", time_zone]
          when :week # start on Sunday, not Redshift default Monday
            # Redshift does not return timezone information; it
            # always says it is in UTC time, so we must convert
            # back to UTC to play properly with the rest of Groupdate.
            #
            ["CONVERT_TIMEZONE(?, 'Etc/UTC', DATE_TRUNC(?, CONVERT_TIMEZONE(?, #{column}) - INTERVAL '#{week_start} day' - INTERVAL '#{day_start} second'))::timestamp + INTERVAL '#{week_start} day' + INTERVAL '#{day_start} second'", time_zone, field, time_zone]
          else
            ["CONVERT_TIMEZONE(?, 'Etc/UTC', DATE_TRUNC(?, CONVERT_TIMEZONE(?, #{column}) - INTERVAL '#{day_start} second'))::timestamp + INTERVAL '#{day_start} second'", time_zone, field, time_zone]
          end
        when 'SQLite'
          if field == "week"
            ["strftime('%%Y-%%m-%%d 00:00:00 UTC', #{column}, '-6 days', 'weekday 0')"]
          else
            format =
              case field
                when :hour_of_day
                  "%H"
                when :day_of_week
                  "%w"
                when :second
                  "%Y-%m-%d %H:%M:%S UTC"
                when :minute
                  "%Y-%m-%d %H:%M:00 UTC"
                when :hour
                  "%Y-%m-%d %H:00:00 UTC"
                when :day
                  "%Y-%m-%d 00:00:00 UTC"
                when :month
                  "%Y-%m-01 00:00:00 UTC"
                when :year
                  "%Y-01-01 00:00:00 UTC"
                else
                  raise "Unrecognized grouping: #{field}."
                end
              ["strftime('#{format.gsub(/%/, '%%')}', #{column})"]
          end
        else
          raise "Connection adapter not supported: #{adapter_name}"
        end

      if adapter_name == "MySQL" && field == :week
        query[0] = "CAST(#{query[0]} AS DATETIME)"
      end

      group = relation.group(Groupdate::OrderHack.new(relation.send(:sanitize_sql_array, query), field, time_zone))
      relation =
        if time_range.is_a?(Range)
          # doesn't matter whether we include the end of a ... range - it will be excluded later
          group.where("#{column} >= ? AND #{column} <= ?", time_range.first, time_range.last)
        else
          group.where("#{column} IS NOT NULL")
        end

      # TODO do not change object state
      @group_index = group.group_values.size - 1

      Groupdate::Series.new(self, relation)
    end
  end
end