class AppPerfAgentWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key,
                :name,
                :host,
                :hostname,
                :data,
                :user,
                :application,
                :protocol_version

  def perform(params, body)
    #AppPerfRpm.without_tracing do
      json = decompress_params(body)

      self.license_key      = params.fetch("license_key") { nil }
      self.protocol_version = params.fetch("protocol_version") { nil }
      self.hostname         = json.fetch("host")
      self.name             = json.fetch("name") { nil }

      if self.license_key.nil? ||
         self.protocol_version.nil?
        return
      end

      self.data = Array(json.fetch("data"))

      self.application = Application.where(:license_key => license_key).first_or_initialize
      self.application.name = name
      self.application.save

      self.host = Host.where(:name => hostname).first_or_create

      if protocol_version.to_i.eql?(2)
        errors, remaining_data = data.partition {|d| d[0] == "error" }
        metrics, spans = Array(remaining_data).partition {|d| d[0] == "metric" }

        if metrics.present?
          process_metric_data(metrics)
        end

        if errors.present? && application.present?
          process_error_data(errors)
        end

        if spans.present? && application.present?
          process_version_2(spans)
        end
      end
    #end
  end

  private

  def decompress_params(body)
    compressed_body = Base64.decode64(body)
    data = Zlib::Inflate.inflate(compressed_body)
    MessagePack.unpack(data)
  end

  def load_data(data)
    data
      .map {|datum|
        begin
          _layer, _trace_key, _start, _duration, _serialized_opts = datum
          _opts = _serialized_opts
        rescue => ex
          Rails.logger.error "SERIALIZATION ERROR"
          Rails.logger.error ex.message.to_s
          Rails.logger.error _serialized_opts.inspect
          _opts = {}
        end

        trace_key = generate_trace_id(_trace_key)

        begin
          [_layer, trace_key, _start.to_f, _duration.to_f, _opts]
        rescue => ex
          Rails.logger.error "LOAD DATA ERROR"
          Rails.logger.error "DATA: #{datum.inspect}"
          Rails.logger.error "PARSED DATA: #{[_layer, _trace_key, _start, _duration, _serialized_opts].inspect}"
          raise
        end
      }
  end

  def load_layers(data)
    existing_layers = application.layers.all
    layer_names = data.map {|d| d[0] }.compact.uniq
    new_layers = (layer_names - existing_layers.map(&:name)).map {|l|
      layer = application.layers.where(:name => l).first_or_initialize
      layer.save
      layer
    }
    (new_layers + existing_layers).uniq {|l| l.name }
  end

  def load_database_types(data)
    existing_database_types = application.database_types.all
    database_type_names = data
      .map {|d| d[4]["adapter"] }
      .compact
      .uniq
    new_database_types = (database_type_names - existing_database_types.map(&:name)).map {|adapter|
      database_type = application.database_types.where(
        :name => adapter
      ).first_or_initialize
      database_type.save
      database_type
    }
    (new_database_types + existing_database_types).uniq {|l| l.name }
  end

  def load_traces(data)
    traces = []
    timestamps = data
      .group_by {|datum| datum[1] }
      .flat_map {|trace_key, events| { trace_key => events.map {|e| e[2] }.max } }
      .reduce({}) { |h, v| h.merge v }
    durations = data
      .group_by {|datum| datum[1] }
      .flat_map {|trace_key, events| { trace_key => events.map {|e| e[3] }.max } }
      .reduce({}) { |h, v| h.merge v }

    trace_keys = data.map {|d| d[1] }.compact.uniq
    existing_traces = application.traces.where(:trace_key => trace_keys)

    trace_keys.each {|trace_key|
      timestamp = Time.at(timestamps[trace_key])
      duration = durations[trace_key]

      trace = existing_traces.find {|t| t.trace_key == trace_key }
      if trace.nil?
        trace = application.traces.new(:trace_key => trace_key)
      end

      trace.host = host
      trace.trace_key = trace_key

      # Set timestamp if never set, or incoming timestamp is earlier than
      # the oldest recorded already.
      if trace.timestamp.nil? || trace.timestamp > timestamp
        trace.timestamp = timestamp
      end

      # Set the duration if never set, or the incoming duration is slower
      # than the previous.
      if trace.duration.nil? || trace.duration < duration
        trace.duration = duration
      end

      if trace.new_record?
        traces << trace
      else
        trace.save
      end
    }
    ids = Trace.import(traces).ids

    application.traces.where(:trace_key => trace_keys).all
  end

  def process_version_2(data)
    events = []
    spans = []
    database_calls = []
    backtraces = []

    data = load_data(data)
    layers = load_layers(data)
    database_types = load_database_types(data)
    traces = load_traces(data)

    data.each do |_layer, _trace_key, _start, _duration, _opts|
      hash = {}

      layer = layers.find {|l| l.name == _layer }

      endpoint = nil
      database_call = nil
      url = _opts.fetch("url") { nil }
      domain = _opts.fetch("domain") { nil }
      controller = _opts.fetch("controller") { nil }
      action = _opts.fetch("action") { nil }
      query = _opts.fetch("query") { nil }
      adapter = _opts.fetch("adapter") { nil }
      _backtrace = _opts.delete("backtrace")

      timestamp = Time.at(_start)
      duration = _duration

      if query
        database_type = database_types.find {|dt| dt.name == adapter }
        database_call = application.database_calls.new(
          :uuid => SecureRandom.uuid.to_s,
          :database_type_id => database_type.id,
          :host_id => host.id,
          :layer_id => layer.id,
          :statement => query,
          :timestamp => timestamp,
          :duration => _duration
        )
        database_calls << database_call
      end

      span = {}
      if database_call
        span[:grouping_id] = database_call.uuid.to_s
        span[:grouping_type] = "DatabaseCall"
      end
      span[:host_id] = host.id
      span[:layer_id] = layer.id
      span[:timestamp] = timestamp
      span[:duration] = _duration
      span[:trace_id] = _trace_key
      span[:uuid] = SecureRandom.uuid.to_s
      span[:payload] = _opts

      if _backtrace
        backtrace = Backtrace.new
        backtrace.backtrace = _backtrace
        backtrace.backtraceable_id = span[:uuid]
        backtrace.backtraceable_type = "Span"
        backtraces << backtrace
      end

      spans << span
    end

    all_events = []
    spans.select {|s| s[:trace_id] }.group_by {|s| s[:trace_id] }.each_pair do |trace_key, events|
      trace = traces.find {|t| t.trace_key == trace_key }
      next if trace.nil?
      timestamp = events.map {|e| e[:timestamp] }.min
      duration = events.map {|e| e[:duration] }.max
      url = (events.find {|e| e[:payload]["url"] } || {}).fetch(:payload, {}).fetch("url") { nil }
      domain = (events.find {|e| e[:payload]["domain"] } || {}).fetch(:payload, {}).fetch("domain") { nil }
      controller = (events.find {|e| e[:payload]["controller"] } || {}).fetch(:payload, {}).fetch("controller") { nil }
      action = (events.find {|e| e[:payload]["action"] } || {}).fetch(:payload, {}).fetch("action") { nil }
      events.each { |e|
        e[:payload]["url"] ||= url
        e[:payload]["domain"] ||= domain
        e[:payload]["controller"] ||= controller
        e[:payload]["action"] ||= action
        e[:trace_id] = trace.trace_key
      }

      existing_spans = trace.spans.all
      new_spans = events.map {|s| application.spans.new(s) }
      all_spans = existing_spans + new_spans
      all_spans.each {|s| s.exclusive_duration = get_exclusive_duration(s, all_spans) }

      all_spans.select {|s| s.id.present? }.each(&:save)

      all_events += new_spans
    end


    Backtrace.import(backtraces)
    Span.import(all_events)
    DatabaseCall.import(database_calls)
  end

  def get_exclusive_duration(span, spans)
    children_data = span_children_data(span, spans)
    children_data.size > 0 ? children_duration(children_data) : span.duration
  end

  def span_children_data(span, spans)
    spans
      .select {|s| span.parent_of?(s) }
  end

  def children_duration(children)
    children
      .map {|span| span.duration.to_f / 1000 }
      .inject(0) {|sum, x| sum + x }
  end

  def generate_trace_id(seed = nil)
    if seed.nil?
      Digest::SHA1.hexdigest([Time.now, rand].join)
    else
      Digest::SHA1.hexdigest(seed)
    end
  end

  def process_analytic_event_data(data)
    analytic_event_data = []
    data.each do |datum|
      datum[:host_id] = host.id
      analytic_event_data << application.analytic_event_data.new(datum)
    end
    AnalyticEventDatum.import(analytic_event_data)
  end

  def process_error_data(data)
    error_data = []
    data.select {|d| d.first.eql?("error") }.each do |datum|
      _, trace_key, timestamp, data = datum
      message, backtrace, fingerprint = generate_fingerprint(data["message"], data["backtrace"])

      error_message = application.error_messages.where(:fingerprint => fingerprint).first_or_initialize
      error_message.error_class ||= data["error_class"]
      error_message.error_message ||= message
      error_message.last_error_at = Time.now
      error_message.save

      error_data << application.error_data.new do |error_datum|
        error_datum.host = host
        error_datum.error_message = error_message
        error_datum.transaction_id = trace_key
        error_datum.message = message
        error_datum.backtrace = backtrace
        error_datum.source = data["source"]
        error_datum.timestamp = timestamp
      end
    end
    ErrorDatum.import(error_data)
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

  def generate_fingerprint(message, backtrace)
    message, fingerprint = ErrorMessage.generate_fingerprint(message)
    return message, backtrace, fingerprint
  end
end
