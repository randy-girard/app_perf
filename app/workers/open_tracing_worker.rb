class OpenTracingWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key,
                :name,
                :host,
                :data,
                :user,
                :organization,
                :application,
                :protocol_version

  def perform(params, body)
    AppPerfRpm.without_tracing do
      license_key      = params.fetch("license_key") { nil }
      protocol_version = params.fetch("protocol_version") { nil }

      if license_key.nil? ||
         protocol_version.nil? ||
         !protocol_version.to_i.eql?(3)
        return
      end

      json     = decompress_params(body)
      hostname = json.fetch("host")
      name     = json.fetch("name") { nil }
      data     = Array(json.fetch("data"))

      set_organization(license_key, name)

      if organization
        if data.present? && application.present?
          set_host(hostname)
          layers = load_layers(data)
          process_data(layers, data)
        end
      end
    end
  end

  private

  def set_organization(license_key, name)
    self.organization = Organization.where(:license_key => license_key).first

    if organization
      if name.present?
        self.application = organization.applications.where(:name => name).first_or_initialize
        application.save
      end
      # We couldn't find a user, so lets find an application
    elsif self.application = Application.where(:license_key => license_key).first
      self.organization = application.organization
    else
      return
    end
  end

  def set_host(hostname)
    self.host = organization.hosts.where(:name => hostname).first_or_create
  end

  def decompress_params(body)
    compressed_body = Base64.decode64(body)
    data = Zlib::Inflate.inflate(compressed_body)
    JSON.load(data)
  end

  def load_layers(data)
    data
      .map {|datum| datum["tags"]["component"] || datum["name"] }
      .uniq
      .map {|layer|
        layer = application.layers.where(:name => layer).first_or_initialize
        layer.organization = organization
        layer.save
        layer
      }
  end

  def process_data(layers, data)
    spans = build_spans(layers, data)
    log_entries = build_log_entries(data)
    backtraces = build_backtraces(log_entries)
    error_datum = build_errors(log_entries)
    database_calls = build_database_calls(spans)
    traces = build_traces(spans)

    Backtrace.import(backtraces)
    Span.import(spans)
    LogEntry.import(log_entries)
    ErrorDatum.import(error_datum)
    DatabaseCall.import(database_calls)
    Trace.import(traces)
  end

  def build_backtraces(log_entries)
    backtraces = []
    log_entries
      .select {|log_entry| log_entry["event"] == "backtrace" }
      .each {|log_entry|
        fields = log_entry["fields"]
        _backtrace = fields["stack"] || fields[":stack"]
        if _backtrace
          backtrace = Backtrace.new
          backtrace.backtrace = _backtrace
          backtrace.backtraceable_id = log_entry.span_id
          backtrace.backtraceable_type = "Span"
          backtraces << backtrace
        end
      }
    backtraces
  end

  def build_spans(layers, data)
    data.map {|datum|
      span = Span.new
      span.organization_id = organization.id
      span.application_id = application.id
      span.host_id = host.id
      span.uuid = datum["id"]
      span.operation_name = datum["name"]
      span.trace_id = datum["traceId"]
      span.parent_id = datum["parentId"]
      span.name = datum["name"]
      span.layer_id = layers.find {|l| l.name == (datum["tags"]["component"] || datum["name"]) }.id
      span.timestamp = Time.at(datum["timestamp"].to_f)
      span.duration = datum["duration"].to_f
      span.payload = datum["tags"]
      span.exclusive_duration = get_exclusive_duration(span, data)
      span
    }
  end

  def build_log_entries(data)
    data.map {|datum|
      datum["logEntries"].map {|log_data|
        log_entry = LogEntry.new
        log_entry.span_id = datum["id"]
        log_entry.trace_id = datum["traceId"]
        log_entry.event = log_data["event"]
        log_entry.timestamp = Time.at(log_data["timestamp"].to_f)
        log_entry.fields = log_data["fields"]
        log_entry
      }
    }.flatten
  end

  def generate_fingerprint(message, backtrace)
    message, fingerprint = ErrorMessage.generate_fingerprint(message)
    return message, backtrace, fingerprint
  end

  def build_errors(log_entries)
    log_entries
      .select {|log_entry| log_entry.event == "error" }
      .map {|log_entry|
        error = log_entry.fields
        message = error[":message"] || error["message"]
        backtrace = error[":backtrace"] || error["backtrace"]
        error_class = error[":error_class"] || error["error_class"]
        source = error[":source"] || error["source"]

        message, backtrace, fingerprint = generate_fingerprint(message, backtrace)

        error_message = application.error_messages.where(:fingerprint => fingerprint).first_or_initialize
        error_message.organization = organization
        error_message.error_class ||= error_class
        error_message.error_message ||= message
        error_message.last_error_at = Time.now
        error_message.save

        error_datum = application.error_data.new
        error_datum.host = host
        error_datum.span_id = log_entry.span_id
        error_datum.organization = organization
        error_datum.error_message = error_message
        error_datum.transaction_id = log_entry.trace_id
        error_datum.message = message
        error_datum.backtrace = backtrace
        error_datum.source = source
        error_datum.timestamp = log_entry.timestamp
        error_datum
      }
  end

  def get_database_types(spans)
    spans
      .select {|span| span.payload.has_key?("db.type") }
      .map {|span| span.tag("db.vendor") }
      .uniq
      .map {|adapter|
        database_type = DatabaseType.where(
          :name => adapter,
          :application_id => application.id,
          :organization_id => organization.id
        ).first_or_initialize
        database_type.organization_id = organization.id
        database_type.application_id = application.id
        database_type.save
        database_type
      }
  end

  def build_database_calls(spans)
    database_types = get_database_types(spans)
    spans
      .select {|span| span.payload.has_key?("db.type") }
      .map {|span|
        database_type = database_types.find {|dt| dt.name == span.tag("db.vendor") }
        database_call = DatabaseCall.new
        database_call.database_type_id = database_type.id
        database_call.organization_id = organization.id
        database_call.application_id = application.id
        database_call.span_id = span.uuid
        database_call.host_id = host.id
        database_call.layer_id = span.layer_id
        database_call.statement = span.tag("db.statement")
        database_call.timestamp = span.timestamp
        database_call.duration = span.duration
        database_call
      }
  end

  def build_traces(spans)
    spans
      .select(&:is_root?)
      .map {|span|
        trace = Trace.new
        trace.organization_id = organization.id
        trace.application_id = application.id
        trace.host_id = host.id
        trace.trace_key = span.trace_id
        trace.timestamp = span.timestamp
        trace.duration = span.duration
        trace
      }
  end

  def get_exclusive_duration(span, data)
    children = span_children_data(span, data)
    span.duration - (children.size > 0 ? children_duration(children) : 0)
  end

  def span_children_data(span, data)
    data
      .select {|datum| datum["parentId"] == span.uuid }
  end

  def children_duration(children)
    children
      .map {|datum| datum["duration"].to_f / 1000 }
      .inject(0) {|sum, x| sum + x }
  end
end
