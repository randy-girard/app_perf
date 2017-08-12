class TracesController < ApplicationController
  def index
    @traces = @current_application
      .traces
      .select("traces.*, spans.payload->>'url' AS url, COUNT(spans.id) AS spans_count")
      .joins(:spans)
      .order("timestamp DESC")
      .group("traces.id, spans.payload->>'url'")
      .distinct
      .page(params[:page])
  end

  def show
    @database_call = params[:query]
    @layer_names = @current_application.layers.pluck(:name)
    @trace = @current_application
      .traces
      .includes(:spans => :layer)
      .where(:trace_key => params[:id])
      .first
    @spans = @trace.spans.sort_by(&:timestamp)
    @span = @spans.find {|s| s.id == params[:sample_id].to_i }

    @database_calls = @current_application
      .database_calls
      .select("database_calls.statement AS query, COUNT(database_calls.*) AS count, AVG(database_calls.duration) as avg_duration, SUM(database_calls.duration) AS total_duration")
      .joins(:database_span)
      .where(:spans => { :id => @spans })
      .group("database_calls.statement")

    group_index = 0
    item_index = 0
    @groups = []
    @items = []
    @spans.group_by {|s| s.layer.name }.each_pair do |layer_name, spans|
      @groups << { :id => group_index, :content => layer_name, :value => group_index + 1 }
      spans.each do |span|
        if layer_name == "rack-middleware"
          duration = span.exclusive_duration
        else
          duration = span.duration
        end
        @items << {
          :id => span.id,
          :group => group_index,
          :content => "",
          :start => span.timestamp.to_f * 1000,
          :end => (span.timestamp.to_f * 1000) + duration.to_f,
          :className => "app-perf-color-#{layer_name}"
        }
        item_index += 1
      end
      group_index += 1
    end


    @root_with_children = @trace.arrange_spans
  end

  def database
    @trace = @current_application
      .traces
      .includes(:spans => :layer)
      .where(:trace_key => params[:id])
      .first
    @spans = @trace.spans
    @database_calls = @current_application
      .database_calls
      .select("database_calls.statement AS query, COUNT(database_calls.*) AS count, AVG(database_calls.duration) as avg_duration, SUM(database_calls.duration) AS total_duration")
      .joins(:database_span)
      .where(:spans => { :id => @spans })
      .group("database_calls.statement")
    render :layout => false
  end
end
