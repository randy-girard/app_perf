class TransactionsController < ApplicationController

  def index
    @transactions = @application.transaction_data
      .where(:category => "action_controller")
      .group_by {|t| t.payload[:end_point] }
  end

end