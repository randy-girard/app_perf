class DatabaseController < ApplicationController

  def index
    @transactions = @application.transaction_data
      .where(:category => "active_record")
      .group_by {|t| t.payload[:end_point] }
  end

end