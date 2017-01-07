class TracesController < ApplicationController
  def index
    @traces = @current_application
      .traces
      .order("timestamp DESC")
      .page(params[:page])
  end

  def show
    @database_call = params[:query]
    @trace = @current_application
      .traces
      .where(:trace_key => params[:id])
      .first
    @samples = @trace.transaction_sample_data

    @root_with_children = @trace.arrange_samples
  end
end
