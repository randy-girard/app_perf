class DatabaseController < ApplicationController

  def index
    @database_calls = @current_application
      .database_calls
      .where(:timestamp => @time_range)
      .order("duration DESC")
      .page(params[:page])
  end

end
