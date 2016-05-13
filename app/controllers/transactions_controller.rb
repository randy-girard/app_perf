class TransactionsController < ApplicationController

  def index
    @transactions = @application.transaction_data
      .where(:category => "action_controller")
      .group_by {|t| t.payload[:end_point] }
  end

  def show
    @transaction = @application.transaction_data.find(params[:id])
    @transaction_samples = @application.transaction_data.where(:request_id => @transaction.request_id)
  end

end