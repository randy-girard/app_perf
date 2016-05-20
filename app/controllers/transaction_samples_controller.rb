class TransactionSamplesController < ApplicationController

  def show
    @transaction = @current_application.transaction_endpoints.find(params[:transaction_id])
    @transaction_sample = @current_application.transaction_sample_data.find(params[:id])
  end

end