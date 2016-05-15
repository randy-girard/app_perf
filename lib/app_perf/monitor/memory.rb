module AppPerf
  module Monitor
    class Memory < AppPerf::Monitor::Base
      def active?
        true
      end

      def instrument
        {
          :name => "Memory",
          :timestamp => round_time(Time.now, 60).to_s,
          :value => `ps -o rss= -p #{Process.pid}`.to_i
        }
      end
    end
  end
end
