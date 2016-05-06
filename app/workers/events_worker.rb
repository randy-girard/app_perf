class EventsWorker < ActiveJob::Base
  queue_as :app_perf

  def perform(params)
    license_key = params.delete(:license_key)
    host = params.delete(:host)

    application = Application.find_by_license_key(license_key)
    application.metrics.create(params)
  end
end