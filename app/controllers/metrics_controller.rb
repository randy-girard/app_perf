class MetricsController < ApplicationController
  def index
    @host = @current_organization.hosts.find(params[:host_id])
    @reporter = MetricReporter.new(@host, params, view_context)
    render :json => @reporter.report_data
  end

  def show
    @data = if params[:v] == "1"
      MetricDataService
        .new(@current_organization, params[:id], params)
        .call
    else
      MetricDataServiceTwo
        .new(@current_organization, params[:id], params)
        .call
    end

    render :json => @data
  end
end
