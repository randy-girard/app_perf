require 'zlib'

module AppPerf
  class Store

    def initialize
      @start_time = Time.now
      @queue = []
    end

    def save(events)
      return if events.empty?

      @queue.push AppPerf::NestedEvent.arrange(events, :presort => false)
    end


    def dispatch
      if Time.now > @start_time + 60.seconds
        dispatch_events(@queue.dup)
        @queue.clear
        @start_time = Time.now
      end
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

      def dispatch_events(events)
        Thread.new {
          uri = URI(url)
          req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json", "Accept-Encoding" => "gzip", "User-Agent" => "gzip" })
          req.body = {
            "host" => AppPerf.host,
            "license_key" => AppPerf.config["license_key"],
            "events" => events
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
