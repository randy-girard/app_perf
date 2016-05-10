module AppPerf
  module Instrument
    class Errors < AppPerf::Instrument::Base

      def initialize
        super /^ruby\.errors/
      end

      def prepare(event)
        Rails.logger.info "ERROR: #{event.inspect}"
      end

    end
  end
end
