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
        when "analytic_event_data"
          process_analytic_event_data(data)
        when "transaction_data"
          process_transaction_data(data)
        when "transaction_sample_data"
          process_transaction_sample_data(data)
        when "error_data"
          process_error_data(data)
        else
          Rails.logger.info "Unknown method."
        end
      end
    end
  end

  private

  def process_analytic_event_data(data)
    analytic_event_data = []
    data.each do |datum|
      datum[:host_id] = host.id
      analytic_event_data << application.analytic_event_data.new(datum)
    end
    AnalyticEventDatum.import(analytic_event_data)
  end

  def process_transaction_sample_data(data)
    transaction_sample_data = []
    data.each do |datum|
      children = datum.delete(:children)
      # Hack right now to get the request_id. Ideally this would be
      # part of the bulk load as well.
      endpoint = datum.delete(:end_point)
      transaction_endpoint = application.transaction_endpoints.where(:name => endpoint).first_or_create
      database_group = process_database_data(datum)
      transaction_sample_datum = application.transaction_sample_data.new(datum)
      transaction_sample_datum.application = application
      transaction_sample_datum.host = host
      transaction_sample_datum.transaction_endpoint = transaction_endpoint
      transaction_sample_datum.grouping = database_group
      transaction_sample_datum.save
      transaction_sample_datum.request_id = transaction_sample_datum.id
      transaction_sample_datum.save
      process_transaction_sample_data_children(transaction_sample_data, transaction_sample_datum, children)
    end

    TransactionSampleDatum.import(transaction_sample_data, recursive: true)
  end

  def process_transaction_sample_data_children(transaction_sample_data, transaction_sample_datum, data, depth = 1)
    if data.present?
      data.each do |child_datum|
        children = child_datum.delete(:children)

        endpoint = child_datum.delete(:end_point)
        transaction_endpoint = application.transaction_endpoints.where(:name => endpoint).first_or_create
        database_group = process_database_data(child_datum)
        child = transaction_sample_datum.children.build(child_datum)
        child.transaction_endpoint = transaction_endpoint
        child.application = application
        child.grouping = database_group
        child.host = host
        child.request_id = transaction_sample_datum.request_id || transaction_sample_datum.id
        process_transaction_sample_data_children(transaction_sample_data, child, children, depth + 1) if children.present?
        transaction_sample_data << child if depth.eql?(1)
      end
    end
  end

  def process_transaction_data(data)
    event_data = []
    data.each do |datum|
      endpoint = datum.delete(:end_point)
      transaction_endpoint = application.transaction_endpoints.where(:name => endpoint).first_or_create
      datum[:transaction_endpoint_id] = transaction_endpoint.id
      datum[:host_id] = host.id
      event_data << application.transaction_data.new(datum)
    end
    TransactionDatum.import(event_data)
  end

  def process_error_data(data)
    error_data = []
    data.each do |datum|
      message, backtrace, fingerprint = generate_fingerprint(datum[:payload][:message], datum[:payload][:backtrace])

      error_message = application.error_messages.where(:fingerprint => fingerprint).first_or_initialize
      error_message.error_class ||= datum[:payload][:error_class]
      error_message.error_message ||= message
      error_message.last_error_at = Time.now
      error_message.save

      error_data << application.error_data.new do |error_datum|
        error_datum.host = host
        error_datum.error_message = error_message
        error_datum.transaction_id = datum[:transaction_id]
        error_datum.message = message
        error_datum.backtrace = backtrace
        error_datum.timestamp = datum[:timestamp]
      end
    end
    ErrorDatum.import(error_data)
  end

  def generate_fingerprint(message, backtrace)
    message, fingerprint = ErrorMessage.generate_fingerprint(message)
    return message, backtrace, fingerprint
  end

  def process_database_data(data)
    if ["active_record", "sequel"].include?(data[:category])
      name = "PostgreSQL"
      database_type = application.database_types.where(:name => name).first_or_create
      application.database_calls.where(
        :name => data[:payload][:name],
        :database_type_id => database_type.id
      ).first_or_create
    end
  end
end