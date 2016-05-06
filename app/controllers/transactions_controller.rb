class TransactionsController < ApplicationController

  def index
    @transactions = @application.metrics
      .where(:category => "action_controller")
      .group_by {|t| t.payload[:end_point] }
  end

end