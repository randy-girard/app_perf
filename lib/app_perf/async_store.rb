require 'thread'
require 'net/http'

module AppPerf
  class AsyncStore

    # An instrumenter that does not send notifications. This is used in the
    # AsyncStore so saving events does not send any notifications, not even
    # for logging.
    class VoidInstrumenter < ::ActiveSupport::Notifications::Instrumenter
      def instrument(name, payload={})
        yield(payload) if block_given?
      end
    end

    def initialize
      @queue = Queue.new
      @thread = Thread.new do
        set_void_instrumenter
        consume
      end
    end

    def save(events)
      @queue << events
    end

    protected
      def set_void_instrumenter
        Thread.current[:"instrumentation_#{notifier.object_id}"] = VoidInstrumenter.new(notifier)
      end

      def notifier
        ActiveSupport::Notifications.notifier
      end

      def consume
        events_to_dispatch = []
        while events = @queue.pop
          root_event = AppPerf::NestedEvent.arrange(events, :presort => false)
          #root_model = create_metric(root_event)
          #root_model.update_attributes(:request_id => root_model.id)
          #save_tree(root_event.children, root_model.id, root_model.id)

          events_to_dispatch.push(root_event)
        end

        dispatch_events(events_to_dispatch)
      end

      def save_tree(events, request_id, parent_id)
        events.each do |event|
          model = create_metric(event, :request_id => request_id, :parent_id => parent_id)
          save_tree(event.children, request_id, model.id)
        end
      end

      def dispatch_events(events_to_dispatch)
        if events_to_dispatch.present?
          uri = URI('http://localhost:9291/agent_listener')
          req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
          req.body = {"metric" => events_to_dispatch}.to_json
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(req)
          end
        end
      end

      def create_metric(event, merge_params={})
        AppPerf::Metric.create(event.to_hash.merge(merge_params))
      end

  end
end
