module Enumerable
  def chart_json(function = nil)
    if is_a?(Hash) && (key = keys.first) && key.is_a?(Array)
      group_by { |k, _v| k[0] }.map do |name, data|
        {
          name: name,
          data: data.map { |k, v| [k[1], v] }
        }
      end
    else
      if self.is_a?(Hash)
        self.each do |(k, v)|
          case function
          when ".per_second()"
            self[k].each {|(key, value)|
              self[k][key] = self[k][key] / 60
            }
          end
        end
      else
        self[k] = self[k] / 60
      end

      self
    end
  end
end

 module API
  module V1
    class Metrics < Roda
      include API::V1::Defaults
      include API::V1::Authentication

      route do |r|
        @params = r.params.symbolize_keys

        #require_login!(r)

        @time_range, @period = Reporter.time_range(@params)
        @application = Application.find_by_id(@params[:application_id])

        query = @params[:q]

        parsed_query = query.to_s.match(/([a-z,]*)?(:)?([a-z\*\.,]*)(\{.*?\})?(\..*?)?( by \{.*?\})?$/i)
        groups = []
        fields = []
        calculations ={}

        if parsed_query

          calcs = parsed_query[1].to_s.split(",")
          calcs.each {|calc|
            calculations[calc.to_sym] = case calc
                                        when "count"
                                          "SUM(cte.count) AS count"
                                        when "avg"
                                          "SUM(cte.sum) / SUM(cte.count) AS avg"
                                        when "sum"
                                          "SUM(cte.sum) AS sum"
                                        end
          }

          services = parsed_query[3].to_s.split(",")
          tags_query = parsed_query[4].to_s.gsub(/[\{\}]/, "")
          function = parsed_query[5]

          if (group_query = parsed_query[6])
            groups = group_query.match(/by \{(.*)\}/)[1].split(",")
          end
        end

        timestamp_group = groups.delete("timestamp")

        if tags_query
          tags = tags_query.split(",").map {|t| t.split(":", 2) }
        end

        cte = MetricDatum
          .select("metric_data.timestamp")
          .select("metric_data.count")
          .select("metric_data.sum")
          .select("jsonb_object_agg(tags.key, tags.value) AS tags")
          .joins(:metric, :tags)
          .where(timestamp: @time_range)
          .where("tags.key IS NOT NULL")
          .where("tags.value IS NOT NULL")
          .group("metric_data.timestamp")
          .group("metric_data.count")
          .group("metric_data.sum")
          .group("taggings.uuid")

        if services.present? && services != "*"
          cte = cte.where(metrics: { name: services })
        end

        if tags.present?
          keys = tags.map(&:first) + groups
          cte = cte.where(tags: { key: keys })
        end

        relation = MetricDatum
          .with(cte: cte)
          .from("cte")

        tags.each do |key, value|
          relation = relation.where("tags->>? IS NOT NULL", key)
          relation = relation.where("tags->>? = ?", key, value)
        end

        groups.each do |group|
          relation = relation.where("tags->>? IS NOT NULL", group)
          relation = relation.group("tags->>'#{group}'")
        end

        if timestamp_group
          relation = relation
            .group_by_period(*Reporter.report_params(@params, "cte.timestamp"))
        end

        if calculations.size == 1
          data = relation.calculate_all(calculations.values.first)
        else
          data = relation.calculate_all(calculations)
        end

        #data.each do |(k, v)|
        #  case function
        #  when ".per_second()"
        #    data[k] = data[k] / 60
        #  else
        #    data[k] = data[k]
        #  end
        #end

        {
          data: data.chart_json(function)
        }
        # chart_json(data)
        #hash = data.group_by(&:first).map do |name, datum|
        #  raise name.inspect
        #  grouped_labels, value = *datum

          #h = grouped_labels.reverse.inject(value) { |a, n| { n => a } }

          #{
          #  name: grouped_labels.first,
          #  data: hash.deep_merge!(h)
          #}
        #end

        #hash

        #          {"name" => "Workout","data" =>{"2013-02-10":3,"2013-02-17":3,"2013-02-24":3,"2013-03-03":1,"2013-03-10":4,"2013-03-17":3,"2013-03-24":2,"2013-03-31":3}},
        #          {"name":"Go to concert","data":{"2013-02-10":0,"2013-02-17":0,"2013-02-24":0,"2013-03-03":0,"2013-03-10":2,"2013-03-17":1,"2013-03-24":0,"2013-03-31":0}},
        #          {"name":"Wash face","data":{"2013-02-10":0,"2013-02-17":1,"2013-02-24":0,"2013-03-03":0,"2013-03-10":0,"2013-03-17":1,"2013-03-24":0,"2013-03-31":1}},
        #          {"name":"Call parents","data":{"2013-02-10":5,"2013-02-17":3,"2013-02-24":2,"2013-03-03":0,"2013-03-10":0,"2013-03-17":1,"2013-03-24":1,"2013-03-31":0}},
        ##        ]
      end
    end
  end
end
