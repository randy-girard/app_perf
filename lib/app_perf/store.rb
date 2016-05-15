require 'zlib'

module AppPerf
  class Store

    class VoidInstrumenter < ::ActiveSupport::Notifications::Instrumenter
      def instrument(name, payload={})
        yield(payload) if block_given?
      end
    end

    def initialize
      @queue = Queue.new
    end

    def save(events)
      return if events.empty?
      @queue << events
    end

    def initialize_dispatcher
      thread = Thread.new do
        set_void_instrumenter
        start_time = Time.now
        loop do
          begin
            if Time.now > start_time + 60.seconds && !@queue.empty?
              process_data
              dispatch_events(:analytic_event_data)
              dispatch_events(:transaction_sample_data)
              dispatch_events(:transaction_data)
              dispatch_events(:error_data)
              @queue.clear
              start_time = Time.now
            end
          rescue => ex
            Rails.logger.error "ERROR: #{ex.inspect}"
            Rails.logger.error "#{ex.backtrace.inspect}"
          end
          Rails.logger.flush
          sleep 15
        end
      end
      thread.abort_on_exception = true
    end

    private

    def set_void_instrumenter
      Thread.current[:"instrumentation_#{notifier.object_id}"] = VoidInstrumenter.new(notifier)
    end

    def analytic_event_data
      Thread.current[:app_perf_analytic_event_data] ||= []
    end

    def transaction_sample_data
      Thread.current[:app_perf_transaction_sample_data] ||= []
    end

    def transaction_data
      Thread.current[:app_perf_transaction_data] ||= []
    end

    def error_data
      Thread.current[:app_perf_error_data] ||= []
    end

    def notifier
      ActiveSupport::Notifications.notifier
    end

    def process_data
      all_events = []

      while @queue.size > 0
        events = @queue.pop

        end_point = nil
        if (event = events.find {|e| e.payload[:end_point].present? })
          end_point = event.payload[:end_point]
        end
        events.each {|e| e.payload[:end_point] = end_point }

        root_event = AppPerf::NestedEvent.arrange(events.dup, :presort => false)
        if root_event.duration > 200
          transaction_sample_data.push root_event
        end

        events.select {|e| e.category.eql?("error") }.each do |error|
          error_data << error
        end
        all_events += events.dup
      end

      memory_events = all_events.select {|e| e.category.eql?("memory") }
      memory_events.group_by {|e| round_time(e.started_at, 60) }.each_pair do |timestamp, memory|
        analytic_event_data << {
          :name => "Memory",
          :timestamp => timestamp,
          :value => memory.map(&:duration).sum  / memory.size.to_f
        }
      end

      all_events.group_by {|e| [e.payload[:end_point], round_time(e.started_at, 60)] }.each_pair do |group, grouped_events|
        if group[0].present?

          calls = grouped_events
          db_calls = grouped_events.select {|e| event_name(e) == "Database" }
          gc_calls = grouped_events.select {|e| event_name(e) == "GC Execution" }

          transaction_data << {
            :end_point => group[0],
            :timestamp => group[1],
            :call_count => calls.size,
            :duration => calls.map(&:duration).sum,
            :db_call_count => db_calls.size,
            :db_duration => db_calls.map(&:duration).sum,
            :gc_call_count => gc_calls.size,
            :gc_duration => gc_calls.map(&:duration).sum
          }
        end
      end

      error_data.group_by {|e| round_time(e.started_at, 60) }.each_pair do |timestamp, errors|
        analytic_event_data << {
          :name => "Error",
          :timestamp => timestamp,
          :value => errors.size
        }
      end
    end

    def round_time(t, sec = 1)
      down = t - (t.to_i % sec)
      up = down + sec

      difference_down = t - down
      difference_up = up - t

      if (difference_down < difference_up)
        return down.to_s
      else
        return up.to_s
      end
    end

    def event_name(event)
      case event.category
      when "action_controller"
        "Ruby"
      when "active_record"
        "Database"
      when "action_view"
        "Ruby"
      when "gc"
        "GC Execution"
      when "memory"
        "Memory Usage"
      when "error"
        "Error"
      else
        nil
      end
    end

    def url(method)
      @url ||= {}
      @url[method] ||= [
        AppPerf.config["ssl"] ? "https" : "http",
        "://",
        AppPerf.config["host"],
        ":",
        AppPerf.config["port"],
        "/api/listener/1/#{AppPerf.config["license_key"]}/#{method}"
      ].join
    end

    def dispatch_events(method)
      data = send(method)
      if data.present?
        uri = URI(url(method))
        req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json", "Accept-Encoding" => "gzip", "User-Agent" => "gzip" })
        req.body = {
          "host" => AppPerf.host,
          "data" => data
        }.to_json
        res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.read_timeout = 5
          http.request(req)
        end
        data.clear
      end
    end
  end
end
