class MetricDataServiceTwo
  def initialize(metrics, params)
    self.metrics = metrics
    self.params = params
    self.group_values  = Array(params[:group].split(","))
    self.select_values = Array(params[:select].split(","))
    self.period = params[:period] || "minute"
    self.limit = params[:_limit] || params[:limit]
    self.order = params[:_order] || params[:order]
    self.headers = Array(params[:headers].to_s.split(","))

    time_range, period = Reporter.time_range(params)

    self.time_range = time_range
    self.start_time = time_range.first
    self.end_time = time_range.last
    self.period = period
  end

  def call
    execute
  end

  private

  attr_accessor :metrics,
                :params,
                :headers,
                :group_values,
                :select_values,
                :time_range,
                :start_time,
                :end_time,
                :period,
                :limit,
                :order,
                :aggregate_values

  def execute
    aggregates = build_aggregates

    data = MetricDatum
      .joins(:metric, :host)
      .where(:metrics => { :name => metrics })

    data = host_filter(data)
    data = filter_data(data)
    data = application_filter(data)
    data = filter_time_range(data)
    data = group_data(data)
    data = limit_data(data)
    data = order_data(data)
    data = data.calculate_all(aggregates)
    {
      :data => format_data(data),
      :annotations => annotations
    }
  end

  def host
    @host ||= Host.where(:id => params[:host_id] || params[:_host]).first
  end

  def application
    @application ||= Application.where(:id => params[:application_id]).first
  end

  def host_filter(data)
    data = data.where(:metric_data => { :host_id => host }) if host
    data
  end

  def application_filter(data)
    data = data.where(:metrics => { :application_id => application }) if application
    data
  end

  def filter_data(data)
    if _layer = params[:_layer]
      data = data.where("metric_data.tags ->> 'layer' = ?", _layer)
    end

    if _controller = params[:_controller]
      data = data.where("metric_data.tags ->> 'controller' = ?", _controller)
    end

    if _action = params[:_action]
      data = data.where("metric_data.tags ->> 'action' = ?", _action)
    end

    if _url = params[:_url]
      data = data.where("metric_data.tags ->> 'url' = ?", _url)
    end

    if _domain = params[:_domain]
      data = data.where("metric_data.tags ->> 'domain' = ?", _domain)
    end

    data
  end

  def build_aggregates
    self.aggregate_values = {}
    select_values.each do |select_value|
      divisions = select_value.split("/")
      fragments = divisions.map do |key|
        v = case key
        when "value"
          "SUM(metric_data.value)"
        when "traces"
          "SUM(CASE WHEN metric_data.tags->>'layer' = 'rack' then (metric_data.tags->>'traces')::int else 0 end)"
        else
          "SUM((metric_data.tags->>'#{key}')::int)"
        end
        sanitize_sql("#{v} FILTER (WHERE metrics.name = :metrics)", :metrics => metrics)
      end
      key = divisions.join("_").to_sym
      aggregate_values[key] = "(CASE WHEN #{fragments.last} > 0 THEN #{fragments.join("/")} ELSE 0 END) AS #{key}"
    end
    aggregate_values
  end

  def order_data(data)
    if order
      key = aggregate_values[order.split("/").join("_").to_sym]
      key = key.to_s.split(" AS ").first
      if key
        data = data.order(key).reverse_order
      end
    end
    data
  end

  def filter_time_range(data)
    data.where("timestamp BETWEEN ? AND ?", start_time, end_time)
  end

  def limit_data(data)
    data = data.limit(limit) if limit
    data
  end

  def group_data(data)
    options = {}
    options[:permit] = %w[minute hour day]
    if time_range
      options[:range] = time_range
    else
      options[:last] = (params[:_last] || 60)
    end

    group_values.each do |group_value|
      case group_value
      when "timestamp"
        data = data.group_by_period(period, "metric_data.timestamp", options)
      when "host"
        data = data.group("hosts.name")
      else
        sql = sanitize_sql(
          "metric_data.tags #>> :group_value",
          :group_value => "{#{group_value}}"
        )
        data = data.group(sql)
      end
    end
    data
  end

  def format_data(data)
    case params[:type]
    when "chart"
      format_chart(data)
    else
      format_table(data)
    end
  end

  def format_chart(data)
    hash = []
    groups = {}
    data.each_pair do |(group, timestamp), values|
      value = select_values.map {|s|
        key = s.split("/").join("_")
        values.is_a?(Hash) ? values[key.to_sym].to_f : values.to_f
      }
      groups[group] ||= []
      groups[group] << [timestamp, value.first].flatten
    end

    groups.each_pair do |group, data|
      hash.push({
        :name => group,
        :data => data,
        :color => "##{Digest::MD5.hexdigest(group)[0..5]}",
        :id => "ID-#{group}"
      }) rescue nil
    end

    hash
  end

  def format_table(data)
    hash = {}

    hash[:headers] = if headers.present?
      headers
    else
      (group_values + select_values).flatten
    end

    hash[:data] = data.map do |groupings, values|
      value = select_values.map {|s|
        key = s.split("/").join("_")
        values.is_a?(Hash) ? values[key.to_sym].to_f : values.to_f
      }
      [groupings, value].flatten
    end
    hash
  end

  def sanitize_sql(sql, values)
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, values])
  end

  def annotations
    time_range, period = Reporter.time_range(params)
    Deployment
      .where("start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end", :start => start_time, :end => end_time)
      .map {|deployment|
        {
          :value => deployment.start_time.to_i * 1000,
          :color => '#FF0000',
          :width => 2
        }
      }
  end
end
