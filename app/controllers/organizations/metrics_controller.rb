class Organizations::MetricsController < ApplicationController
  def index
    @host = @current_organization.hosts.find(params[:host_id])
    @reporter = MetricReporter.new(@host, params, view_context)
    render :json => @reporter.report_data
  end
end
