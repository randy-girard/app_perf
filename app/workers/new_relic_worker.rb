class NewRelicWorker

  def initialize(params)
    self.params = params
  end

  def execute
    application = Application.find_by_license_key(params[:license_key])

    response = case params[:method]
    when "get_redirect_host"
      { return_value: 'localhost' }
    when "connect"
      { return_value: { agent_run_id: 1, browser_key: 'xx', application_id: @application.id, js_agent_loader: '' } }
    when "metric_data", "analytic_event_data", "sql_trace_data", "transaction_sample_data", "profile_data", "custom_event_data", "error_event_data", "error_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => params[:method], :body => data)
      { return_value: nil }
    when "get_agent_commands"
      { return_value: [] }
    when "agent_command_results"
      { return_value: [] }
    when "shutdown"
      { return_value: nil }
    else
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => method, :body => data)
      { return_value: nil }
    end
  end

  private

  attr_accessor :params

end