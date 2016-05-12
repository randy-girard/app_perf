class ErrorsController < ApplicationController
  def index
    @errors = @application.error_data
  end

  def show
    @error = @application.error_data.find(params[:id])

    render :json => @error
  end
end
