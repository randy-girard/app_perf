module AppPerf
  module Instrument
    class RubyVm < AppPerf::Instrument::Base

      def initialize
        super /^ruby_vm\.gc$/
      end

      def prepare(event)
        gc_time = GC::Profiler.total_time
        event.duration = gc_time * 1_000
      end

    end
  end
end
