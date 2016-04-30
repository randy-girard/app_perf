class RawDataController < ApplicationController

  def index
    @raw_data = @application.raw_data.order(:id).page(params[:page]).per(25)
  end

  def show
    @raw_datum = @application.raw_data.find(params[:id])

    render :json => @raw_datum
  end
end