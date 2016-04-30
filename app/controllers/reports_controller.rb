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
    if @filter
      @transaction_filter = @application.transactions.where(:name => @filter).first
    end

    @transaction_metric_id = params[:transaction_metric_id]
    if @transaction_metric_id
      @transaction_metric = @application.transaction_metrics.where(:id => @transaction_metric_id).first

      @transaction_metric_samples = @transaction_metric.transaction_metric_samples
    end


    if params.include?(:report_type)
      case params[:report_type]
      when "average_duration"
        @report_data = @application.transaction_metrics
        if @transaction_metric
          @report_data = @report_data.where(:id => @transaction_metric)
        else
          @report_data = @report_data.where(:transaction_id => @transaction_filter) if @transaction_filter
          @report_data = @report_data.group(:name).group_by_minute(:timestamp, range: @range).average(:duration)
        end
      end
    end
  end

  def show
    @filter = params[:filter]
    if @filter
      @transaction_filter = @application.transactions.where(:name => params[:filter]).first
    end

    @transaction_metric_id = params[:transaction_metric_id]
    if @transaction_metric_id
      @transaction_metric = @application.transaction_metrics.where(:id => @transaction_metric_id).first
    end

    case params[:id]
    when "average_duration"
      @report_data = @application.transaction_metrics
      if @transaction_metric
        range = (@transaction_metric.timestamp - 5.minutes)..(@transaction_metric.timestamp + 5.minutes)
        @report_data = @report_data.where(:id => @transaction_metric).group(:name).group_by_minute(:timestamp, range: range).average(:duration)
      else
        @report_data = @report_data.where(:transaction_id => @transaction_filter) if @transaction_filter
        @report_data = @report_data.group_by_minute(:timestamp, range: @range)

        database_duration = @report_data.average(:database_duration)
        gc_duration = @report_data.average(:gc_duration)
        view_duration = @report_data.average("(duration - (database_duration + gc_duration))")

        @report_data = [
          { name: "Garbage Collection", data: gc_duration  },
          { name: "Database Duration", data: database_duration },
          { name: "View Duration", data: view_duration }
        ]
      end
      render :layout => false
    when "memory_physical"
      raw_data = @application.raw_data.where(:method => "metric_data").all
      memory_physical = raw_data.map(&:memory_physical)
      memory_physical = memory_physical.map {|i| [i[:start_at].to_f, i[:value]] }.to_h
      step = 60.seconds
      @report_data = []
      (30.minutes.ago..61.seconds.ago).step(step) do |time|
        memory_physical_value = 0
        memory_physical_tmp = memory_physical.select {|k, v| k >= time.to_f && k < time.to_f + step }
        memory_physical_value = memory_physical_tmp.values.sum / memory_physical_tmp.values.size if memory_physical_tmp.present?
        @report_data << [time.to_f, memory_physical_value]
      end
      render :layout => false
    when "gc_total_objects"
      raw_data = @application.raw_data.where(:method => "metric_data").all
      gc_total_allocated_objects = raw_data.map(&:gc_total_allocated_objects)
      gc_total_allocated_objects = gc_total_allocated_objects.map {|i| [i[:start_at].to_f, i[:value]] }.to_h
      step = 60.seconds
      @report_data = []
      (30.minutes.ago..61.seconds.ago).step(step) do |time|
        gc_total_allocated_objects_value = 0
        gc_total_allocated_objects_tmp = gc_total_allocated_objects.select {|k, v| k >= time.to_f && k < time.to_f + step }
        gc_total_allocated_objects_value = gc_total_allocated_objects_tmp.values.sum / gc_total_allocated_objects_tmp.values.size if gc_total_allocated_objects_tmp.present?
        @report_data << [time.to_f, gc_total_allocated_objects_value]
      end
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