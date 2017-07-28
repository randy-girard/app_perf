class Organizations::Applications::SamplesController < ApplicationController
  def show
    @sample = @current_application.transaction_sample_data.find(params[:id])

    render :layout => false
  end
end
