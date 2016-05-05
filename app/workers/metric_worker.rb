class MetricWorker < ActiveJob::Base
  queue_as :app_perf

  def perform(params)
    SystemMetrics::Metric.create(params)
  end
end