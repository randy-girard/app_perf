class ErrorReporter < Reporter

  def report_data
    data = application.analytic_event_data.where(:name => "Error")

    [{
      :name => "Errors",
      :data => data.group_by_period(*report_params).sum(:value)
    }]
  end
end
