class DatabaseController < ApplicationController

  def index
    @database_calls = @current_application
      .database_calls
      .where(:timestamp => @time_range)
      .order("timestamp DESC")
      .page(params[:page])

    if params[:_layer]
      @database_calls = @database_calls.joins(:span).where("spans.layer_id = ?", params[:_layer])
    end
  end

end
