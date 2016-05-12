class EventsWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key, :host, :method, :data, :application, :protocol_version

  def perform(params)
    self.license_key      = params.fetch(:license_key)
    self.protocol_version = params.fetch(:protocol_version)
    self.host             = params.fetch(:host)
    self.method           = params.fetch(:method)
    self.data             = Array(params.fetch(:data))

    self.application = Application.find_by_license_key(license_key)
    if application
      self.host = application.hosts.where(:name => host).first_or_create

      if protocol_version.to_i.eql?(1)
        case method
        when "event_data"
          process_event_data(data)
        when "error_data"
          process_error_data(data)
        when "transaction_data"
          process_transaction_data(data)
        else
          Rails.logger.info "Unknown method."
        end
      end
    end
  end

  private

  def process_transaction_data(data)
    data.each do |datum|
      application.raw_data.create do |raw_datum|
        raw_datum.host = host
        raw_datum.body = datum
        raw_datum.method = datum[:name]
      end
      application.transaction_data.create(datum) do |transaction_datum|
        transaction_datum.host = host
      end
    end
  end

  def process_event_data(data)
    data.each do |datum|
      application.event_data.create do |event_datum|
        event_datum.host = host
        event_datum.name = datum[:name]
        event_datum.timestamp = datum[:timestamp]
        event_datum.num = datum[:num]
        event_datum.value = datum[:value]
        event_datum.avg = datum[:value].to_f / datum[:num].to_f
      end
    end
  end

  def process_error_data(data)
    data.each do |datum|
      application.error_data.create do |error_datum|
        error_datum.host = host
        error_datum.transaction_id = datum[:transaction_id]
        error_datum.message = datum[:payload][:message]
        error_datum.backtrace = datum[:payload][:backtrace]
        error_datum.timestamp = datum[:started_at]
      end
    end
  end
end