module SystemMetrics
  module Instrument
    class Rack < SystemMetrics::Instrument::Base

      def initialize
        super /^request\.rack$/
      end

    end
  end
end
