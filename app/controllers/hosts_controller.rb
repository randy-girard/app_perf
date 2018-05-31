class HostsController < ApplicationController
  def index
    @hosts = Host
      .joins(:metric_data)
      .where("metric_data.timestamp >= ?", 1.day.ago)
      .distinct
  end

  def show
    @host = Host.find(params[:id])
  end
end
