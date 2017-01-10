class MetricReporter < Reporter

  def report_data
    time_range, period = Reporter.time_range(params)

    metrics = application
      .metrics
      .where(:name => params[:name])
      .joins(:host)
      .group_by_period(*report_params("timestamp"))
      .average(:value)

    hash = []
    metrics.each_pair do |timestamp, value|
      hash << [timestamp.to_i * 1000, value]
    end

    deployments = application
      .deployments
      .where("start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end", :start => time_range.first, :end => time_range.last)

    {
      :data => [{
        :label => "Memory",
        :data => hash
      }],
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
