module SystemMetrics
  module Instrument
    class ActionView < SystemMetrics::Instrument::Base

      def initialize
        super /\.action_view$/
      end

      def prepare(event)
        event.payload.each do |key, value|
          case value
          when NilClass
          when String
            event.payload[key] = prune_path(value)
          else
            event.payload[key] = value
          end
        end
      end

    end
  end
end
