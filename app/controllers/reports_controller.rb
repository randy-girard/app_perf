module RangeWithStepTime
  def step(step_size = 1, &block)
    return to_enum(:step, step_size) unless block_given?

    # Defer to Range for steps other than durations on times
    return super unless step_size.kind_of? ActiveSupport::Duration

    # Advance through time using steps
    time = self.begin
    op = exclude_end? ? :< : :<=
    while time.send(op, self.end)
      yield time
      time = step_size.parts.inject(time) { |t, (type, number)| t.advance(type => number) }
    end

    self
  end
end

Range.prepend(RangeWithStepTime)

class ReportsController < ApplicationController

  before_action :set_range

  def index
    @filter = params[:filter]
    @metric_id = params[:metric_id]

    @hosts = @application.hosts

    if @metric_id
      @transaction_metrics = @application.metrics.where(:id => @metric_id)
      @transaction_metric_samples = @application.metrics.where(:parent_id => @metric_id)
    elsif @filter
      @transaction_metrics = @application.metrics.where(:end_point => @filter)
    else
      @transaction_metrics = @application.metrics
        .group(:end_point)
        .where(:started_at => @range)
        .select("metrics.end_point, AVG(duration) AS duration")
    end
  end

  def show
    @filter = params[:filter]
    @report_data = []

    @metric_id = params[:metric_id]
    if @metric_id
      @transaction_metric = @application.metrics.where(:id => @metric_id).first
      @range = (@transaction_metric.started_at - 5.minutes)..(@transaction_metric.started_at + 5.minutes)
    end

    case params[:id]
    when "average_duration"
      data = @application.event_data
      database_data = data.where(:name => "Database")
      ruby_data = data.where(:name => "Ruby")
      gc_data = data.where(:name => "GC Execution")

      @report_data.push({ :name => "GC Execution", :data => gc_data.group_by_minute(:timestamp, range: @range).average(:value) }) if gc_data.present?
      @report_data.push({ :name => "Database", :data => database_data.group_by_minute(:timestamp, range: @range).average(:value) }) if database_data.present?
      @report_data.push({ :name => "Ruby", :data => ruby_data.group_by_minute(:timestamp, range: @range).average(:value) }) if ruby_data.present?
      @report_colors = ["#4E4318", "#EECC45", "#A5FFFF"]

      render :layout => false
    when "memory_physical"
      data = @application.event_data.where(:name => "Memory Usage")
      @report_data.push({ :name => "Memory Usage", :data => data.group_by_minute(:timestamp, range: @range).average(:value) }) if data.present?
      @report_colors = ["#A5FFFF"]
      render :layout => false
    when "gc_total_objects"
      @report_data = @application.metrics.where(:name => "RubyVM/GC/total_allocated_object").group_by_minute(:timestamp, range: @range).average(:value)
      render :layout => false
    else
      render :json => @raw_datum
    end
  end

  def new
    data = Application.select("pg_sleep(5)").first

    render :json => data
  end

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end