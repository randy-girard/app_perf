class Stats::AnnotationsService < Stats::BaseService
  def call
    application
      .deployments
      .where("start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end", :start => time_range.first, :end => time_range.last)
      .each_with_index
      .map {|deployment, index|
        {
          type: 'line',
          id: 'event-#{index}',
          mode: 'vertical',
          scaleID: 'x-axis-0',
          value: deployment.start_time.to_i * 1_000,
          borderColor: 'red',
          borderWidth: 1,
          label: {
            enabled: true,
            position: "center",
            content: deployment.title
          }
        }
      }
  end
end
