class MetricsController < ApplicationController
  def index
    @host = Host.find(params[:host_id])
    @reporter = MetricReporter.new(@host, params, view_context)
    render :json => @reporter.report_data
  end

  def show
    @data = if params[:v] == "1"
      MetricDataService
        .new(params[:id], params)
        .call
    else
      MetricDataServiceTwo
        .new(params[:id], params)
        .call
    end

    render :json => @data
  end
end
