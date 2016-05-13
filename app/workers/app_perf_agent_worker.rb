class AppPerfAgentWorker < ActiveJob::Base
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
    raw_data = []
    transaction_data = []

    data.each do |datum|
      raw_data << application.raw_data.new do |raw_datum|
        raw_datum.host = host
        raw_datum.body = datum
        raw_datum.method = datum[:name]
      end

      children = datum.delete(:children)
      # Hack right now to get the request_id. Ideally this would be
      # part of the bulk load as well.
      transaction_datum = application.transaction_data.new(datum)
      transaction_datum.application = application
      transaction_datum.host = host
      transaction_datum.save
      transaction_datum.request_id = transaction_datum.id
      transaction_datum.save
      process_transaction_data_children(transaction_data, transaction_datum, children)
    end

    RawDatum.import(raw_data)
    TransactionDatum.import(transaction_data, recursive: true)
  end

  def process_transaction_data_children(transaction_data, transaction_datum, data, depth = 1)
    if data.present?
      data.each do |child_datum|
        children = child_datum.delete(:children)
        child = transaction_datum.children.build(child_datum)
        child.application = application
        child.host = host
        child.request_id = transaction_datum.request_id || transaction_datum.id
        process_transaction_data_children(transaction_data, child, children, depth + 1) if children.present?
        transaction_data << child if depth.eql?(1)
      end
    end
  end

  def process_event_data(data)
    event_data = []
    data.each do |datum|
      event_data << application.event_data.new do |event_datum|
        event_datum.host = host
        event_datum.name = datum[:name]
        event_datum.timestamp = datum[:timestamp]
        event_datum.num = datum[:num]
        event_datum.value = datum[:value]
        event_datum.avg = datum[:value].to_f / datum[:num].to_f
      end
    end
    EventDatum.import(event_data)
  end

  def process_error_data(data)
    error_data = []
    data.each do |datum|
      error_data << application.error_data.new do |error_datum|
        error_datum.host = host
        error_datum.transaction_id = datum[:transaction_id]
        error_datum.message = datum[:payload][:message]
        error_datum.backtrace = datum[:payload][:backtrace]
        error_datum.timestamp = datum[:started_at]
      end
    end
    ErrorDatum.import(error_data)
  end
end