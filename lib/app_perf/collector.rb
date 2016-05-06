module AppPerf
  class Collector
    attr_reader :store

    def initialize(store)
      @store = store
      @start_time = Time.now
    end

    def collect_event(event)
      events.push event if AppPerf.collecting?
    end

    def collect
      events.clear
      AppPerf.collection_on
      result = yield
      AppPerf.collection_off
      dispatch_events
      result
    ensure
      AppPerf.collection_off
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
        Thread.current[:app_perf_events] ||= []
      end

  end
end
