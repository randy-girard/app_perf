require 'securerandom'

class AppPerfAgentWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key,
                :name,
                :host,
                :data,
                :user,
                :application,
                :protocol_version

  alias_attribute :jid, :job_id

  def perform(params, body)
    #AppPerfRpm.without_tracing do
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

      set_user(license_key)
      set_application(license_key, name)

      if data.present? && application.present?
        set_host(hostname)

        metrics, spans = Array(data).partition {|d| d[0] == "metric" }

        if metrics.present?
          process_metric_data(metrics)
        end

        if spans.present? && application.present?
          layers = load_layers(data)
          process_data(layers, spans)
        end
      end
    #end
  end

  private

  def set_user(license_key)
    self.user = User.where(license_key: license_key).first
  end

  def set_application(license_key, name)
    self.application = Application.where(:license_key => license_key).first_or_initialize
    self.application.user = user
    self.application.name = name
    self.application.save
  end

  def set_host(hostname)
    self.host = Host.where(name: hostname).first_or_create
  end

  def decompress_params(body)
    compressed_body = Base64.decode64(body)
    data = Zlib::Inflate.inflate(compressed_body)
    MessagePack.unpack(data)
  end

  def load_layers(data)
    data
      .map {|datum| datum["tags"]["component"] || datum["name"] }
      .uniq
      .map {|layer|
        layer = application.layers.where(:name => layer).first_or_initialize
        layer.save
        layer
      }
  end

  def process_data(layers, data)
    data = set_exclusive_durations(data)
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
      # span.id = SecureRandom.uuid.to_s
      span.application_id = application.id
      span.host_id = host.id
      span.uuid = datum["id"]
      span.operation_name = datum["name"]
      span.trace_key = datum["traceId"]
      span.parent_id = datum["parentId"]
      span.name = datum["name"]
      span.layer_id = layers.find {|l| l.name == (datum["tags"]["component"] || datum["name"]) }.id
      span.timestamp = Time.at(datum["timestamp"].to_f)
      span.duration = datum["duration"].to_f
      if ((!datum["tags"]["db.type"].blank?) && (datum["tags"]["db.type"] == "redis"))
        if (!datum["tags"]["db.statement"].blank?)
          datum["tags"]["db.statement"] = 'redis query'
        end
      end
      span.payload = datum["tags"]
      span.exclusive_duration = datum["exclusiveDuration"].to_f
      span
    }
  end

  def build_log_entries(data)
    data.map {|datum|
      datum["logEntries"].map {|log_data|
        log_entry = LogEntry.new
        log_entry.span_id = datum["id"]
        log_entry.trace_id = datum["traceId"]
        log_entry.event = log_data["event"] || log_data["fields"]["event"]
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
        error_message.error_class ||= error_class
        error_message.error_message ||= message
        error_message.last_error_at = Time.now
        error_message.save

        error_datum = application.error_data.new
        error_datum.host = host
        error_datum.span_id = log_entry.span_id
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
          :application_id => application.id
        ).first_or_initialize
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
        trace.application_id = application.id
        trace.host_id = host.id
        trace.trace_key = span.trace_key
        trace.timestamp = span.timestamp
        trace.duration = span.duration
        trace
      }
  end

  def set_exclusive_durations(data)
    data.map {|datum|
      datum["exclusiveDuration"] = get_exclusive_duration(datum, data)
      datum
    }
  end

  def get_exclusive_duration(span, data)
    # return the exclusive duration if we already set it on this span.
    #return span["exclusiveDuration"] if span.has_key?("exclusiveDuration")

    # does this span have any children?
    children = span_children_data(span, data)
    children_duration = if children.size > 0

      # if the span has children, sum up the durations.
      Array(children).inject(0) do |sum, child|
        sum + child["duration"]
      end
    else
      # If the span doesn't have any children, then the exclusive duration
      # is 0. We will subtract this from the duration later to make the
      # exclusive duration equal to the duration.
      0
    end
    span["duration"] - children_duration
  end

  def span_children_data(span, data)
    data
      .select {|datum| datum["id"] != span["id"] }
      .select {|datum| datum["parentId"] != nil }
      .select {|datum| datum["parentId"] == span["id"] }
  end

  def process_metric_data(data)
    metrics = {}
    metric_data = []

    data.select {|d| d.first.eql?("metric") }.each do |datum|
      _, timestamp, key, value, tags = *datum

      if key && value
        metrics[key] ||= Metric.where(name: key, application_id: application.try(:id)).first_or_create

        metric_data << metrics[key].metric_data.new do |metric_datum|
          metric_datum.host = host
          metric_datum.value = value
          metric_datum.tags = tags || {}
          metric_datum.timestamp = Time.at(timestamp)
        end
      end
    end
    MetricDatum.import(metric_data)
  end
end
