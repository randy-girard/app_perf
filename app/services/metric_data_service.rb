class MetricDataService
  def initialize(metric_name, params = {})
    self.metric_name = metric_name
    self.params = params

    time_range, period = Reporter.time_range(params)

    self.time_range = time_range
    self.start_time = time_range.first
    self.end_time = time_range.last
    self.period = period
  end

  def to_relation
    data = metric_data
    data = host_filter(data)
    data = application_filter(data)
    data = group(data)
    data = filter_time_range(data)
  end

  def call
    to_json
  end

  private

  attr_accessor :metric_name,
                :params,
                :time_range,
                :start_time,
                :end_time,
                :period

  def to_data
    data = to_relation
    data = aggregate(data)
    data = format_data(data)

    return {
      :data => data,
      :annotations => annotations
    }
  end

  def to_json
    to_data.to_json
  end

  def metric_names
    @metric_names ||= metric_name.to_s.split(",")
  end

  def host
    @host ||= Host.find(params[:host_id])
  end

  def application
    @application ||= Application.find_by_id(params[:application_id])
  end

  def metric_data
    @metric_data ||= MetricDatum
      .joins(:metric)
      .where(:metrics => { :name => metric_names })
  end

  def host_filter(data)
    data = data.where(:metric_data => { :host_id => host }) if host
    data
  end

  def application_filter(data)
    data = data.where(:metrics => { :application_id => application }) if application
    data
  end

  def group(data)
    options = {}
    options[:permit] = %w[minute hour day]
    if time_range
      options[:range] = time_range
    else
      options[:last] = (params[:_last] || 60)
    end

    data = data.group_by_period(period, "timestamp", options)

    if params[:group] == "name"
      data.group("name")
    elsif params[:group].present?
      sql = ActiveRecord::Base.send(:sanitize_sql_array, ["tags #>> ?", "{#{params[:group]}}"])
      data = data.group(sql)
    else
      data
    end
  end

  def scale
    (params[:scale] || 1).to_i
  end

  def by
    params[:by]
  end

  def filter_time_range(data)
    data.where("timestamp BETWEEN ? AND ?", start_time, end_time)
  end

  def aggregate(data)
    case params[:aggregate]
    when "sum"
      data.sum("value")
    when "max"
      data.maximum("value")
    when "min"
      data.minimum("value")
    else
      if by
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["CASE WHEN SUM((tags #>> :by)::int) = 0 THEN 0 ELSE SUM(value) / SUM((tags #>> :by)::int) END", :by => "{#{by}}"])
        data.calculate_all(sql)
      else
        data.average("value")
      end
    end
  end

  # Currently there is a limitation that you cannot use multiple metric names AND grouping.
  def format_data(data)
    hash = []
    groups = {}
    data.each_pair do |group, event|
      if params[:group]
        timestamp, metric, group = *group
        groups[metric] ||= []
        groups[metric] << [timestamp, event / scale]
      else
        groups[metric_names.join(" + ")] ||= []
        groups[metric_names.join(" + ")] << [group, event / scale]
      end
    end

    groups.each_pair do |group, data|
      hash.push({
        :name => group,
        :data => data,
        :color => "##{Digest::MD5.hexdigest(group)[0..5]}",
        :id => "ID-#{group}"
      }) rescue nil
    end

    if hash.empty?
      if params[:group]
        metric_names.each do |metric_name|
          hash.push({
            :name => metric_name,
            :data => []
          })
        end
      else
        hash.push({
          :name => metric_names.join(" + "),
          :data => []
        })
      end
    end

    hash
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
