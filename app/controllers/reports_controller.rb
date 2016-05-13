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

    @plot_options = {
      :area => {
        :stacking => "normal"
      }
    }

    case params[:id]
    when "average_duration"
      data = @application.event_data
      database_data = data.where(:name => "Database")
      ruby_data = data.where(:name => "Ruby")
      gc_data = data.where(:name => "GC Execution")

      @range = (data.first.timestamp - 5.minutes)..(data.first.timestamp + 5.minutes)

      @report_data.push({ :name => "Ruby", :data => ruby_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(value) / SUM(num)") }) if ruby_data.present?
      @report_data.push({ :name => "Database", :data => database_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(value) / SUM(num)") }) if database_data.present?
      @report_data.push({ :name => "GC Execution", :data => gc_data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(value) / SUM(num)") }) if gc_data.present?
      @report_colors = ["#A5FFFF", "#EECC45", "#4E4318"]

      render :layout => false
    when "memory_physical"
      data = @application.event_data.where(:name => "Memory Usage")
      @report_data.push({ :name => "Memory Usage", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(value) / SUM(num)") }) if data.present?
      @report_colors = ["#A5FFFF"]
      render :layout => false
    when "errors"
      data = @application.event_data.where(:name => "Error")
      @report_data.push({ :name => "Errors", :data => data.group_by_minute(:timestamp, range: @range).calculate_all("SUM(num)") }) if data.present?
      @report_colors = ["#D3DE00"]
      render :layout => false
    else
      render :json => @raw_datum
    end
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