class OverviewController < ApplicationController

  before_action :set_range

  def show
    @filter = params[:filter]
    @transaction_id = params[:transaction_id]

    @hosts = @application.hosts

    if @transaction_id
      @transaction_metric = @application.transaction_data.where(:id => @transaction_id).first
      @transaction_metric_samples = @application.transaction_data.where(:request_id => @transaction_metric.request_id)
    elsif @filter
      @transaction_metrics = @application.transaction_data.where(:end_point => @filter, :started_at => @range)
    else
      @transaction_metrics = @application.transaction_data
        .group(:end_point)
        .where(:started_at => @range)
        .select("transaction_data.end_point, AVG(duration) AS duration")
    end
  end

  private

  def set_range
    @range = (Time.now - 10.minutes)..Time.now
  end
end