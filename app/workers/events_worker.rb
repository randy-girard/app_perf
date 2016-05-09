class EventsWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key, :host, :method, :events, :application, :protocol_version

  def perform(params)
    self.license_key      = params.fetch(:license_key)
    self.protocol_version = params.fetch(:protocol_version)
    self.host             = params.fetch(:host)
    self.method           = params.fetch(:method)
    self.events           = Array(params.fetch(:events))

    self.application = Application.find_by_license_key(license_key)
    if application
      self.host = application.hosts.where(:name => host).first_or_create

      if protocol_version.to_i.eql?(1)
        case method
        when "event_data"
          process_event_data(events)
        else
          process_data(events)
          Rails.logger.info "Unknown method."
        end
      end
    end
  end

  private

  def process_data(events)
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

  def process_event_data(events)
    events.each do |event|
      application.event_data.create do |event_datum|
        event_datum.host = host
        event_datum.name = event[:name]
        event_datum.timestamp = event[:timestamp]
        event_datum.num = event[:num]
        event_datum.value = event[:value]
        event_datum.avg = event[:value].to_f / event[:num].to_f
      end
    end
  end
end