class ReportsController < ApplicationController

  def show
    @reporter = case params[:id]
      when "average_duration"
        DurationReporter.new(@current_application, params, view_context)
      when "memory_physical"
        MemoryReporter.new(@current_application, params, view_context)
      when "errors"
        ErrorReporter.new(@current_application, params, view_context)
      end

    render :layout => false
  end

  def new
    data = Application.select("pg_sleep(5)").first

    render :json => data
  end

  def error
    raise 'Hello'
  end
end
