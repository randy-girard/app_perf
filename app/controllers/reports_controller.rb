class ReportsController < ApplicationController

  def show
    AppPerfRpm.without_tracing do
      @reporter = case params[:id]
        when "average_duration"
          DurationReporter.new(@current_application, params, view_context)
        when "memory_physical"
          MemoryReporter.new(@current_application, params, view_context)
        when "errors"
          ErrorReporter.new(@current_application, params, view_context)
        when "database"
          DatabaseReporter.new(@current_application, params, view_context)
        when "database_samples"
          DatabaseSampleReporter.new(@current_application, params, view_context)
        end
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @reporter.report_data }
    end
  end

  def new
    data = Application.select("pg_sleep(5)").first

    render :json => data
  end

  def error
    raise 'Hello'
  end
end
