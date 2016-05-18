class ErrorsController < ApplicationController
  def index
    @errors = @current_application
      .error_data
      .group("REGEXP_REPLACE(error_data.message, ':0x[0-9a-z].*\>', '>')")
      .select("MAX(error_data.id) AS id, REGEXP_REPLACE(error_data.message, ':0x[0-9a-z].*\>', '>') AS message, MAX(error_data.timestamp) AS timestamp, COUNT(*) AS count")
      .order("MAX(error_data.timestamp) DESC")
  end

  def show
    @error = @current_application.error_data.find(params[:id])

    render :json => @error
  end
end
