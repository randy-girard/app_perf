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
    @samples = @trace.transaction_sample_data

    @root_with_children = @trace.arrange_samples

    if params[:sample_id]
      @sample = @samples.find {|s| s.id.to_s == params[:sample_id] }
    end
  end
end
