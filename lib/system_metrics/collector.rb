module SystemMetrics
  class Collector
    attr_reader :store

    def initialize(store)
      @store = store
      @start_time = Time.now
    end

    def collect_event(event)
      events.push event if SystemMetrics.collecting?
    end

    def collect
      events.clear
      SystemMetrics.collection_on
      result = yield
      SystemMetrics.collection_off
      dispatch_events
      result
    ensure
      SystemMetrics.collection_off
      events.clear
    end

    private

      def dispatch_events
        if Time.now > @start_time + 5.seconds
          store.save events.dup
          @start_time = Time.now
        end
      end

      def events
        Thread.current[:system_metrics_events] ||= []
      end

  end
end
