module AppPerf
  module Instrument
    class Rack < AppPerf::Instrument::Base

      def initialize
        super /^request\.rack$/
      end

    end
  end
end
