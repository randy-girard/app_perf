module AppPerf
  module Instrument
    class Memory < AppPerf::Instrument::Base

      def initialize
        super /^ruby\.memory$/
      end

      def active?
        true
      end

      def after
        instrument "ruby.memory"
      end

      def prepare(event)
        event.duration = `ps -o rss= -p #{Process.pid}`.to_i
      end

    end
  end
end
