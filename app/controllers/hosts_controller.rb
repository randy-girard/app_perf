class HostsController < ApplicationController
  def index
    @hosts = Tag
      .select("
        tags.value AS name,
        MIN(tags.id) AS id,
        MAX(metric_data.timestamp) AS last_metric_activity")
      .joins(:metric_data)
      .where("tags.key = ?", "host")
      .where("metric_data.timestamp IS NOT NULL")
      .where("metric_data.timestamp >= ?", 1.day.ago)
      .group("tags.value")
  end

  def show
    @host = Tag
      .where(id: params[:id])
      .first
  end
end
