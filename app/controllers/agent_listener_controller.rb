require 'base64'
require 'json'
require 'zlib'
require 'stringio'

class AgentListenerController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!

  def create
    params.permit!
    license_key = params.delete(:license_key)
    host = params.delete(:host)
    events = params.delete(:events)
    method = params.delete(:method)

    hash = {
      :method => method,
      :license_key => license_key,
      :host => host,
      :events => events
    }

    EventsWorker.perform_later(hash)

    render :text => "", :status => :ok
  end

  def invoke_raw_method
    #render :json => []
    #return
    Rails.logger.info params.inspect

    @application = Application.find_by_license_key(params[:license_key])


    response = case params[:method]
    when "get_redirect_host"
      { return_value: 'localhost' }
    when "connect"
      { return_value: { agent_run_id: 1, browser_key: 'xx', application_id: @application.id, js_agent_loader: '' } }
    when "metric_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "metric_data", :body => data)
      { return_value: [] }
    when "analytic_event_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "analytics_event_data", :body => data)
      { return_value: nil }
    when "sql_trace_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "sql_trace_data", :body => data)
      { return_value: nil }
    when "transaction_sample_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "transaction_sample_data", :body => data)
      { return_value: nil }
    when "profile_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "profile_data", :body => data)
      { return_value: nil }
    when "custom_event_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "custom_event_data", :body => data)
      { return_value: nil }
    when "error_event_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "error_event_data", :body => data)
      { return_value: nil }
    when "error_data"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => "error_data", :body => data)
      { return_value: 'ok' }
    when "get_agent_commands"
      { return_value: [] }
    when "agent_command_results"
      { return_value: [] }
    when "shutdown"
      { return_value: nil }
    else
      Rails.logger.info "INVALID METHOD: #{method}"
      data = parse_body(request)
      RawDatum.create(:application_id => @application.id, :method => method, :body => data)
      { return_value: nil }
    end

    render :json => response, :status => :ok
  end

  private

  def parse_body(request)
    request.body.rewind
    body = request.body.read
    body = Zlib::Inflate.inflate(body)
    JSON.parse body
  end
end

