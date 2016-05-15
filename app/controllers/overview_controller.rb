class OverviewController < ApplicationController

  before_action :set_range

  def show
    @hosts = @application.hosts
    @transactions = @application.transaction_endpoints

    @transaction_samples = @application
      .transaction_sample_data
      .where(:started_at => @range)
      .reject {|t| t.payload[:end_point].blank? }
      .group_by {|t| t.payload[:end_point] }
  end

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end