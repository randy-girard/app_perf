class SpansController < ApplicationController
  def show
    @span = @current_application.spans.find(params[:id])

    render :layout => false
  end
end
