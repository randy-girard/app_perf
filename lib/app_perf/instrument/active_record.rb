module AppPerf
  module Instrument
    class ActiveRecord < AppPerf::Instrument::Base

      def initialize
        super /\.active_record$/
      end

      def ignore?(event)
        event.payload[:sql] !~ /^(SELECT|INSERT|UPDATE|DELETE)/
      end

      def prepare(event)
        event.payload[:sql] = event.payload[:sql].squeeze(" ")
        event.payload.delete(:connection_id)
        event.payload.delete(:binds)
      end

    end
  end
end
