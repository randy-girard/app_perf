class DatabaseController < ApplicationController

  def index
    @database_calls = @current_application
      .database_calls
      .joins(:database_samples)
      .where(:transaction_sample_data => { :timestamp => @time_range })
      .group("database_calls.id")
      .select("database_calls.*, SUM(transaction_sample_data.exclusive_duration) AS duration")
      .order("SUM(transaction_sample_data.exclusive_duration) DESC")
    @total_duration = @database_calls.map(&:duration).sum
  end

end