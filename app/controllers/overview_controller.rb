class OverviewController < ApplicationController

  before_action :set_range

  def show
    @hosts = @application.hosts
    @transactions = @application
      .transaction_endpoints
      .joins(:transaction_sample_data)
      .group("transaction_endpoints.id")
      .having("COUNT(transaction_sample_data.id) > 0")
  end

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end