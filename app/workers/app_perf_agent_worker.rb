class AppPerfAgentWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key,
                :name,
                :host,
                :data,
                :user,
                :application,
                :protocol_version

  def perform(params)
    AppPerfRpm.without_tracing do
      self.license_key      = params.fetch(:license_key) { nil }
      self.protocol_version = params.fetch(:protocol_version) { nil }
      self.host             = params.fetch(:host)
      self.name             = params.fetch(:name) { nil }

      if self.license_key.nil? ||
         self.protocol_version.nil? ||
         self.name.nil?
        return
      end

      self.data             = Array(params.fetch(:data))
      self.user             = User.find_by_license_key(license_key)
      self.application      = user.applications.where(:name => name).first_or_initialize
      self.application.license_key = license_key
      if self.application.new_record?
        self.application.data_retention_hours = DEFAULT_DATA_RETENTION_HOURS
      end
      self.application.save

      if application
        self.host = application.hosts.where(:name => host).first_or_create

        if protocol_version.to_i.eql?(2)
          errors, remaining_data = data.partition {|d| d[0] == "error" }
          metrics, samples = Array(remaining_data).partition {|d| d[0] == "metric" }

          if metrics.present?
            process_metric_data(metrics)
          end

          if errors.present?
            process_error_data(errors)
          end

          if samples.present?
            process_version_2(samples)
          end
        end

        # TODO: Move this to a job/cron to run for all
        # apps on a regular basis.
        perform_data_retention_cleanup
      end
    end
  end

  private

  def perform_data_retention_cleanup
    DataRetentionJanitor.new.perform(application.id)
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
      application.layers.where(:name => l).first_or_create
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
      ).first_or_create
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
    samples = []
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
      sample_type = _opts.fetch("type") { "web" }
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

      sample = {}
      if database_call
        sample[:grouping_id] = database_call.uuid.to_s
        sample[:grouping_type] = "DatabaseCall"
      end
      sample[:sample_type] = sample_type
      sample[:host_id] = host.id
      sample[:layer_id] = layer.id
      sample[:timestamp] = timestamp
      sample[:duration] = _duration
      sample[:trace_key] = _trace_key
      sample[:uuid] = SecureRandom.uuid.to_s
      sample[:payload] = _opts
      sample[:url] = url
      sample[:domain] = domain
      sample[:controller] = controller
      sample[:action] = action

      if _backtrace
        backtrace = Backtrace.new
        backtrace.backtrace = _backtrace
        backtrace.backtraceable_id = sample[:uuid]
        backtrace.backtraceable_type = "TransactionSampleDatum"
        backtraces << backtrace
      end

      samples << sample
    end

    all_events = []
    samples.select {|s| s[:trace_key] }.group_by {|s| s[:trace_key] }.each_pair do |trace_key, events|
      trace = traces.find {|t| t.trace_key == trace_key }
      timestamp = events.map {|e| e[:timestamp] }.min
      duration = events.map {|e| e[:duration] }.max
      url = (events.find {|e| e[:url] } || {}).fetch(:url) { nil }
      domain = (events.find {|e| e[:domain] } || {}).fetch(:domain) { nil }
      controller = (events.find {|e| e[:controller] } || {}).fetch(:controller) { nil }
      action = (events.find {|e| e[:action] } || {}).fetch(:action) { nil }
      events.each { |e|
        e[:url] ||= url
        e[:domain] ||= domain
        e[:controller] ||= controller
        e[:action] ||= action
        e[:trace_id] = trace.id
      }

      #root = arrange(events, trace)
      #flattened_sample = flatten_sample(root)
      existing_samples = trace.transaction_sample_data.all
      new_samples = events.map {|s| application.transaction_sample_data.new(s) }
      all_samples = existing_samples + new_samples
      root_event = trace.arrange_samples(all_samples)
      set_exclusive_durations(root_event)

      all_samples.select {|s| s.id.present? }.each(&:save)

      all_events += new_samples
    end


    Backtrace.import(backtraces)
    TransactionSampleDatum.import(all_events)
    DatabaseCall.import(database_calls)
  end

  def set_exclusive_durations(root)
    children = if root.children
      root.children.map {|c| set_exclusive_durations(c) }
    else
      []
    end
    root.exclusive_duration ||= root.duration - children.inject(0.0) { |sum, child| sum + child.duration }
    root
  end

  def arrange(events, trace)
    while event = events.shift
      if parent = events.find { |n|
          start = (n[:timestamp] - event[:timestamp])
          start <= 0 && (start + n[:duration] >= event[:duration])
        }
        parent[:children] ||= []
        parent[:children] << event
      elsif events.empty?
        root = event
      end
    end
    root
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
      message, backtrace, fingerprint = generate_fingerprint(data[:message], data[:backtrace])

      error_message = application.error_messages.where(:fingerprint => fingerprint).first_or_initialize
      error_message.error_class ||= data[:error_class]
      error_message.error_message ||= message
      error_message.last_error_at = Time.now
      error_message.save

      error_data << application.error_data.new do |error_datum|
        error_datum.host = host
        error_datum.error_message = error_message
        error_datum.transaction_id = trace_key
        error_datum.message = message
        error_datum.backtrace = backtrace
        error_datum.source = data[:source]
        error_datum.timestamp = timestamp
      end
    end
    ErrorDatum.import(error_data)
  end

  def process_metric_data(data)
    metrics = []
    data.select {|d| d.first.eql?("metric") }.each do |datum|
      _, timestamp, data = datum

      metrics << application.metrics.new do |metric|
        metric.host = host
        metric.name = data["name"]
        metric.value = data["value"]
        metric.unit = data["unit"]
        metric.timestamp = Time.at(timestamp)
      end
    end
    Metric.import(metrics)
  end

  def generate_fingerprint(message, backtrace)
    message, fingerprint = ErrorMessage.generate_fingerprint(message)
    return message, backtrace, fingerprint
  end
end
