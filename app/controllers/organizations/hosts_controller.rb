class Organizations::HostsController < ApplicationController

  def index
    @hosts = @current_organization.hosts
  end

  def show
    @host = @current_organization.hosts.find(params[:id])
    @metrics = Metric
      .joins(:metric_data)
      .where("metric_data.host_id = ?", @host)
      .where("metrics.name IS NOT NULL")
      .select("metrics.data_type")
      .uniq
  end
end
