class TracesController < ApplicationController
  def index
    @traces = @current_application
      .traces
      .joins(:root_sample)
      .order("timestamp DESC")
      .page(params[:page])
  end

  def show
    @trace = @current_application
      .traces
      .where(:trace_key => params[:id])
      .first
  end
end
