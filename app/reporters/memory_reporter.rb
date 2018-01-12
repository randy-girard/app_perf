class MemoryReporter < Reporter
  def report_data
    data = application.metrics.where(:name => "Memory")

    [{
      :name => "Memory Usage",
      :data => data.group_by_period(*report_params).average(:value)
    }]
  end
end
