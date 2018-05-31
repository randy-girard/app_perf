class TracesController < ApplicationController
  def index
    @traces = @current_application
      .traces
      .includes(:root_span)
      .where("traces.duration IS NOT NULL")
      .where("traces.timestamp IS NOT NULL")
      .order("traces.timestamp DESC")
      .page(params[:page])
  end

  def show
    @database_call = params[:query]

    @trace = @current_application
      .traces
      .includes(:spans => :layer)
      .where(:trace_key => params[:id])
      .first

    @spans = @trace.spans.sort_by(&:timestamp)
    @layer_ids = @spans.map(&:layer_id).uniq
    @layer_names = Layer.where(id: @layer_ids).pluck(:name)
    @span = @spans.find {|s| s.id == params[:span_id] }

    @database_calls = @current_application
      .database_calls
      .joins(:span)
      .where(:spans => { :id => @trace.spans.select(:id) })

    group_index = 0
    item_index = 0
    @groups = []
    @items = []
    @spans.group_by {|s| [s.application, s.layer.name] }.each_pair do |(application, layer_name), spans|

      content = []
      if @current_application.name != application.name
        content << view_context.link_to(application.name, dynamic_url(application, :trace, id: @trace.trace_key))
      end
      content << layer_name

      @groups << { :id => group_index, :content => content.join(": "), :value => group_index + 1 }
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
          :className => "app-perf-color-#{layer_name}#{span.has_error? ? " span-error" : ""}"
        }
        item_index += 1
      end
      group_index += 1
    end
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
      .joins(:span)
      .where(:spans => { :id => @trace.spans.select(:id) })

    render :layout => false
  end
end
