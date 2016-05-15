class TransactionsController < ApplicationController

  def index
    @transactions = @application.transaction_endpoints
  end

  def show
    @transaction = @application.transaction_endpoints.find(params[:id])
    @transaction_samples = @application
      .transaction_sample_data
      .where(:name => "request.rack")
      .where(:transaction_endpoint_id => @transaction)
  end

end