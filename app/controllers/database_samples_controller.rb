class DatabaseSamplesController < ApplicationController
  before_action :set_database_call

  def index
    @database_samples = @database_call
      .database_samples
      .where(:started_at => @time_range)
      .order("exclusive_duration DESC")
    @total_duration = @database_samples.map(&:exclusive_duration).sum
  end

  def show
    @database_sample = @database_call.database_samples.find(params[:id])
  end

  private

  def set_database_call
    @database_call = @current_application.database_calls.find(params[:database_id])
  end

end