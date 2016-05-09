require 'zlib'

module AppPerf
  class Store

    def initialize
      @start_time = Time.now
      @queue = []
      @database_events = []
      @view_events = []
      @gc_events = []
    end

    def save(events)
      return if events.empty?

      @queue += events

      #root_event = AppPerf::NestedEvent.arrange(events, :presort => false)
      #@queue.push root_event
    end

    def collect_events(name, category, events)
      events.map do |event|
        {
          :name => name,
          :timestamp => event.started_at,
          :value => event.duration
        }
      end
    end


    def dispatch
      if Time.now > @start_time + 5.seconds

        events = process_data(@queue.dup)
        dispatch_events(:event_data, events)

        @queue.clear
        @start_time = Time.now
      end
    end

    private

      def process_data(events)
        data = []
        events.group_by {|e| event_name(e) }.each_pair do |name, events_by_name|
          if name
            events_by_name.each do |events_by_time|
              #num = events_by_time.size
              #val = events_by_time.map(&:duration).sum
              #avg = num > 0 ? val.to_f / num.to_f : 0
              if events_by_time.duration > 0
                data << {
                  :name => name,
                  :timestamp => events_by_time.started_at,
                  :value => events_by_time.duration
                }
              end
            end
          end
        end
        data
      end

      def event_name(event)
        case event.category
        when "active_record"
          "Databases"
        when "action_view"
          "Views"
        when "gc"
          "GC Execution"
        else
          nil
        end
      end

      def save_tree(events, request_id, parent_id)
        events.each do |event|
          model = create_metric(event, :request_id => request_id, :parent_id => parent_id)
          save_tree(event.children, request_id, model.id)
        end
      end

      def url(method)
        @url ||= [
          AppPerf.config["ssl"] ? "https" : "http",
          "://",
          AppPerf.config["host"],
          ":",
          AppPerf.config["port"],
          "/api/listener/1/#{AppPerf.config["license_key"]}/#{method}"
        ].join
      end

      def dispatch_events(method, events)
        if events.present?
          Thread.new {
            uri = URI(url(method))
            req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json", "Accept-Encoding" => "gzip", "User-Agent" => "gzip" })
            req.body = {
              "host" => AppPerf.host,
              "events" => events
            }.to_json
            res = Net::HTTP.start(uri.hostname, uri.port) do |http|
              http.read_timeout = 5
              http.request(req)
            end
          }
        end
      end

      def create_metric(event, merge_params={})
        AppPerf::Metric.create(event.to_hash.merge(merge_params))
      end

  end
end
