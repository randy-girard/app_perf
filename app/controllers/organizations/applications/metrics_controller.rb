class Organizations::Applications::MetricsController < ApplicationController
  def index
    @metrics = @current_application
      .metrics
      .where("metrics.name IS NOT NULL")
      .select("metrics.data_type")
      .uniq
  end
end
