module AppPerf
  module Instrument
    class Errors < AppPerf::Instrument::Base

      def initialize
        super /^ruby\.errors$/
      end

      def prepare(event)
      end

    end
  end
end
