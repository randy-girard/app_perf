class TransactionsController < ApplicationController

  def index
    @filter = params[:filter]

    @transaction_samples = @application.transaction_sample_data.where(:category => "action_controller")
    @transaction_samples = @transaction_samples.where(:end_point => @filter) if @filter
    @transaction_samples = @transaction_samples.group_by {|t| t.payload[:end_point] }
  end

  def show
    @transaction_sample = @application.transaction_sample_data.find(params[:id])
    @transaction_samples = @application.transaction_sample_data.where(:request_id => @transaction_sample.request_id)
  end

end