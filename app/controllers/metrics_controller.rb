class MetricsController < ApplicationController
  def index
    @metrics = @current_application
      .metrics
      .where("name IS NOT NULL AND unit IS NOT NULL")
      .select("name, unit")
      .uniq
  end
end
