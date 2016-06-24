class TransactionsController < ApplicationController

  def index
    @transactions = @current_application.transaction_endpoints.includes(:transaction_sample_data)
    @transactions = @transactions.where(:transaction_sample_data => { :timestamp => @time_range }) if @time_range
  end

  def show
    @transaction = @current_application.transaction_endpoints.find(params[:id])
    @transaction_samples = @current_application
      .transaction_sample_data
      .where(:name => "request.rack")
      .where(:transaction_endpoint_id => @transaction)
    @transaction_samples = @transaction_samples.where(:timestamp => @time_range) if @time_range
  end

end