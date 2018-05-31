class MetricReporter < Reporter
  include ActionView::Helpers::NumberHelper

  attr_accessor :host

  def initialize(host, params)
    params[:period] ||= "minute"

    self.host = host
    self.params = params
  end

  def report_data
    time_range, period = Reporter.time_range(params)

    data_type = params[:type]

    relation = @host
      .metric_data
      .joins(:metric)
      .where("metrics.data_type = ?", data_type)
      .group(:name)

    metrics = relation
      .group_by_period(*report_params("timestamp"))
      .average("metric_data.value")

    hash = []
    labels = {}
    metrics.each_pair do |label, value|
      labels[label.first] ||= []
      labels[label.first] << [label.second.to_i * 1000, Metric.metricify(data_type, value)]
    end

    labels.each_pair do |label, data|
      hash.push({ :name => label , :data => data, :id => "ID-#{label}" }) rescue nil
    end

    deployments = Deployment
      .where("start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end", :start => time_range.first, :end => time_range.last)

    {
      :data => hash,
      :events => deployments.map {|deployment|
        {
          :min => deployment.start_time.to_i * 1000,
          :max => deployment.end_time.to_i * 1000,
          :eventType => "Deployment",
          :title => deployment.title,
          :description => deployment.description
        }
      }
    }
  end
end
