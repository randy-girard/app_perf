class HostsController < ApplicationController

  def index
    @hosts = @current_organization
      .hosts
      .joins(:metric_data)
      .where("metric_data.timestamp >= ?", 1.day.ago)
      .distinct
  end

  def show
    @host = @current_organization.hosts.find(params[:id])
  end
end
