class TracesController < ApplicationController
  def index
    @traces = @current_application
      .traces
      .select("traces.*, transaction_sample_data.url AS url, COUNT(transaction_sample_data) AS transaction_sample_data_count")
      .joins(:transaction_sample_data)
      .order("timestamp DESC")
      .group("traces.id, transaction_sample_data.url")
      .distinct
      .page(params[:page])
  end

  def show
    @database_call = params[:query]
    @trace = @current_application
      .traces
      .includes(:transaction_sample_data => :layer)
      .where(:trace_key => params[:id])
      .first
    @samples = @trace.transaction_sample_data.sort_by(&:timestamp)
    @sample = @samples.find {|s| s.id == params[:sample_id].to_i }

    @database_calls = @current_application
      .database_calls
      .select("database_calls.statement AS query, COUNT(database_calls.*) AS count, AVG(database_calls.duration) as avg_duration, SUM(database_calls.duration) AS total_duration")
      .joins(:database_sample)
      .where(:transaction_sample_data => { :id => @samples })
      .group("database_calls.statement")

    group_index = 0
    item_index = 0
    @groups = []
    @items = []
    @samples.group_by {|s| s.layer.name }.each_pair do |layer_name, samples|
      @groups << { :id => group_index, :content => layer_name, :value => group_index + 1 }
      samples.each do |sample|
        @items << {
          :id => sample.id,
          :group => group_index,
          :content => "",
          :start => sample.timestamp.to_f * 1000,
          :end => (sample.timestamp.to_f * 1000) + sample.duration,
          :className => "app-perf-color-#{group_index + 1}"
        }
        item_index += 1
      end
      group_index += 1
    end


    @root_with_children = @trace.arrange_samples
  end

  def database
    @trace = @current_application
      .traces
      .includes(:transaction_sample_data => :layer)
      .where(:trace_key => params[:id])
      .first
    @samples = @trace.transaction_sample_data
    @database_calls = @current_application
      .database_calls
      .select("database_calls.statement AS query, COUNT(database_calls.*) AS count, AVG(database_calls.duration) as avg_duration, SUM(database_calls.duration) AS total_duration")
      .joins(:database_sample)
      .where(:transaction_sample_data => { :id => @samples })
      .group("database_calls.statement")
    render :layout => false
  end
end
