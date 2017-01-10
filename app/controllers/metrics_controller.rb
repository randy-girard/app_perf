class MetricsController < ApplicationController
  def index
    @metric_names = @current_application.metrics.pluck(:name).uniq
  end
end
