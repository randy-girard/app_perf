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

    if @metric_id
      @transaction_metrics = @application.metrics.where(:id => @metric_id)
      @transaction_metric_samples = @application.metrics.where(:parent_id => @metric_id)
    elsif @filter
      @transaction_metrics = @application.metrics.where(:category => @filter)
    else
      @transaction_metrics = @application.metrics
        .group(:category)
        .select("metrics.category, AVG(duration) AS duration")
    end
  end

  def show
    @filter = params[:filter]

    @metric_id = params[:metric_id]
    if @metric_id
      @transaction_metric = @application.metrics.where(:id => @metric_id).first
      @range = (@transaction_metric.started_at - 5.minutes)..(@transaction_metric.started_at + 5.minutes)
    end

    case params[:id]
    when "average_duration"

      @report_data = @application.metrics
      @report_data = @report_data.where(:category => @filter) if @filter
      @report_data = @report_data.where(:id => @transaction_metric) if @transaction_metric
      @report_data = @report_data.group(:category).group_by_minute(:started_at, range: @range).average(:duration)

      #@report_data = @application.transaction_metrics
      #if @transaction_metric
      #  @report_data = @report_data.where(:id => @transaction_metric).group(:name).group_by_minute(:timestamp, range: @range).average(:duration)
      #else
      #  @report_data = @report_data.where(:transaction_id => @transaction_filter) if @transaction_filter
      #  @report_data = @report_data.group_by_minute(:timestamp, range: @range)

      #  database_duration = @report_data.average(:database_duration)
      #  gc_duration = @report_data.average(:gc_duration)
      #  view_duration = @report_data.average("(duration - (database_duration + gc_duration))")

      #  @report_data = [
      #    { name: "Garbage Collection", data: gc_duration  },
      #    { name: "Database Duration", data: database_duration },
      #    { name: "View Duration", data: view_duration }
      #  ]
      #end
      render :layout => false
    when "memory_physical"
      @report_data = @application.metrics.where(:name => "Memory/Physical").group_by_minute(:timestamp, range: @range).average(:value)
      render :layout => false
    when "gc_total_objects"
      @report_data = @application.metrics.where(:name => "RubyVM/GC/total_allocated_object").group_by_minute(:timestamp, range: @range).average(:value)
      render :layout => false
    else
      render :json => @raw_datum
    end
  end

  def new
    data = @application.raw_data.select("pg_sleep(5)").first

    render :json => data
  end

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end