class ErrorsController < ApplicationController
  def index
    @errors = @current_application
      .error_messages
      .joins(:error_data)
      .group("error_messages.id")
      .select("error_messages.*, COUNT(error_data.id) AS instances_count")
      .order("last_error_at DESC")
  end

  def show
    @error = @current_application.error_data.find(params[:id])

    render :json => @error
  end
end
