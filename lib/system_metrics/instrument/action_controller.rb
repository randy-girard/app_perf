module SystemMetrics
  module Instrument
    class ActionController < SystemMetrics::Instrument::Base

      def initialize
        super /\.action_controller$/
      end

      def ignore?(event)
        event.name != 'process_action.action_controller'
      end

      def prepare(event)
        event.payload[:end_point] = "#{event.payload.delete(:controller)}##{event.payload.delete(:action)}"
        event.payload.slice!(:path, :method, :params, :db_runtime, :view_runtime, :end_point)
      end

    end
  end
end
