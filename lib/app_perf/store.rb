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
            if Time.now > start_time + 15.seconds && !@queue.empty?
              process_data
              dispatch_events(:transaction_data)
              dispatch_events(:event_data)
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

    def transaction_data
      Thread.current[:app_perf_transaction_data] ||= []
    end

    def event_data
      Thread.current[:app_perf_event_data] ||= []
    end

    def error_data
      Thread.current[:app_perf_error_data] ||= []
    end

    def notifier
      ActiveSupport::Notifications.notifier
    end

    def process_data
      while @queue.size > 0
        events = @queue.pop

        Rails.logger.info events.inspect
        Rails.logger.flush
        transaction_data.push AppPerf::NestedEvent.arrange(events.dup, :presort => false)

        events.group_by {|e| event_name(e) }.each_pair do |name, events_by_name|
          if name
            events_by_name.group_by {|e| round_time(e.started_at, 5).to_s }.each_pair do |timestamp, events_by_time|
              num = events_by_time.size
              val = events_by_time.map(&:exclusive_duration).sum
              avg = num > 0 ? val.to_f / num.to_f : 0
              event_data << {
                :name => name,
                :num => num,
                :timestamp => timestamp,
                :value => val,
                :avg => avg
              }
            end
          end
        end

        events.select {|e| e.category.eql?("error") }.each do |error|
          error_data << error
        end
      end
    end

    def round_time(t, sec = 1)
      down = t - (t.to_i % sec)
      up = down + sec

      difference_down = t - down
      difference_up = up - t

      if (difference_down < difference_up)
        return down
      else
        return up
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
      Rails.logger.info method.inspect
      data = send(method)
      Rails.logger.info data.inspect
      Rails.logger.flush
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
