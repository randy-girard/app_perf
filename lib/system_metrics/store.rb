module SystemMetrics
  class Store

    def save(events)
      return unless events.present?
      root_event = SystemMetrics::NestedEvent.arrange(events, :presort => false)
      dispatch_events(root_event)
    end

    private

      def save_tree(events, request_id, parent_id)
        events.each do |event|
          model = create_metric(event, :request_id => request_id, :parent_id => parent_id)
          save_tree(event.children, request_id, model.id)
        end
      end

      def dispatch_events(events_to_dispatch)
        Thread.new {
          uri = URI('http://localhost:9291/agent_listener')
          req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
          req.body = {"metric" => events_to_dispatch}.to_json
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.read_timeout = 5
            http.request(req)
          end
        }
      end

      def create_metric(event, merge_params={})
        SystemMetrics::Metric.create(event.to_hash.merge(merge_params))
      end

  end
end
