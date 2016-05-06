module AppPerf
  class Store

    def save(events)
      return unless events.present?
      root_event = AppPerf::NestedEvent.arrange(events, :presort => false)
      dispatch_events(root_event)
    end

    private

      def save_tree(events, request_id, parent_id)
        events.each do |event|
          model = create_metric(event, :request_id => request_id, :parent_id => parent_id)
          save_tree(event.children, request_id, model.id)
        end
      end

      def url
        @url ||= [
          AppPerf.config["ssl"] ? "https" : "http",
          "://",
          AppPerf.config["host"],
          ":",
          AppPerf.config["port"],
          "/agent_listener"
        ].join
      end

      def dispatch_events(events_to_dispatch)
        Thread.new {
          uri = URI(url)
          req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
          req.body = {
            "license_key" => AppPerf.config["license_key"],
            "events" => events_to_dispatch
          }.to_json
          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.read_timeout = 5
            http.request(req)
          end
        }
      end

      def create_metric(event, merge_params={})
        AppPerf::Metric.create(event.to_hash.merge(merge_params))
      end

  end
end
