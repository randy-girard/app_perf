class ReportsController < ApplicationController

  before_action :set_range

  def show
    @report_data = []
    @plot_lines = [
      {
        color: 'red',
        dashStyle: "longdashdot",
        value: "2016-05-10 15:11:00 UTC",
        width: 2
      }
    ]

    case params[:id]
    when "average_duration"
      data = @application.transaction_data
      if params[:transaction_id]
        data = data.where(:transaction_endpoint_id => params[:transaction_id])
      end

      @report_data.push({ :name => "Ruby", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(duration) / SUM(call_count)") }) rescue nil
      @report_data.push({ :name => "Database", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(db_duration) / SUM(db_call_count)") }) rescue nil
      @report_data.push({ :name => "GC Execution", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(gc_duration) / SUM(gc_call_count)") }) rescue nil
      @report_colors = ["#A5FFFF", "#EECC45", "#4E4318"]
      @plot_options = {
        :area => {
          :stacking => "normal"
        }
      }
    when "memory_physical"
      data = @application.analytic_event_data.where(:name => "Memory")
      @report_data.push({ :name => "Memory Usage", :data => data.group_by_minute(:timestamp, range: @range).average(:value) })
      @report_colors = ["#A5FFFF"]
    when "errors"
      data = @application.analytic_event_data.where(:name => "Error")
      @report_data.push({ :name => "Errors", :data => data.group_by_minute(:timestamp, range: @range).sum(:value) })
      @report_colors = ["#D3DE00"]
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

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end