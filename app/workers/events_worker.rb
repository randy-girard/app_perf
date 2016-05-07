class EventsWorker < ActiveJob::Base
  queue_as :app_perf

  def perform(params)
    license_key = params.fetch(:license_key)
    host        = params.fetch(:host)
    events      = Array(params.fetch(:events))

    application = Application.find_by_license_key(license_key)
    if application
      host = application.hosts.where(:name => host).first_or_create
      events.each do |event|
        application.raw_data.create do |raw_datum|
          raw_datum.host = host
          raw_datum.body = event
          raw_datum.method = event[:name]
        end
        application.metrics.create(event) do |metric|
          metric.host = host
        end
      end
    end
  end
end