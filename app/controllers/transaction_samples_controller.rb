class TransactionSamplesController < ApplicationController

  def show
    @transaction = @application.transaction_endpoints.find(params[:transaction_id])
    @transaction_sample = @application.transaction_sample_data.find(params[:id])
    #@transaction_samples = @application.transaction_sample_data.where(:request_id => @transaction_sample.request_id).order(:exclusive_duration).reverse_order
  end

end