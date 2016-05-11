module AppPerf
  class Collector
    attr_reader :store

    def initialize(store)
      @store = store
    end

    def collect_event(event)
      events.push event if AppPerf.collecting?
    end

    def collect
      events.clear
      AppPerf.collection_on
      result = yield
      AppPerf.collection_off
      result
    ensure
      AppPerf.collection_off
      store.save events.dup
      events.clear
    end

    private

    def events
      Thread.current[:app_perf_events] ||= []
    end
  end
end
