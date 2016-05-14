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
      data = data.where(:end_point => params[:filter]) if params[:filter]
      database_data = data.where(:name => "Database")
      ruby_data = data.where(:name => "Ruby")
      gc_data = data.where(:name => "GC Execution")

      if params[:transaction_id]
        @range = (data.first.timestamp - 5.minutes)..(data.first.timestamp + 5.minutes)
      end

      @report_data.push({ :name => "Ruby", :data => ruby_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(duration) / SUM(call_count)") }) if ruby_data.present?
      @report_data.push({ :name => "Database", :data => database_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(db_duration) / SUM(db_call_count)") }) if database_data.present?
      @report_data.push({ :name => "GC Execution", :data => gc_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(gc_duration) / SUM(gc_call_count)") }) if gc_data.present?
      @report_colors = ["#A5FFFF", "#EECC45", "#4E4318"]
      @plot_options = {
        :area => {
          :stacking => "normal"
        }
      }
    when "memory_physical"
      data = @application.transaction_data.where(:name => "Memory Usage")
      @report_data.push({ :name => "Memory Usage", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(duration) / SUM(call_count)") })
      @report_colors = ["#A5FFFF"]
    when "errors"
      data = @application.transaction_data.where(:name => "Error")
      @report_data.push({ :name => "Errors", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(call_count)") })
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