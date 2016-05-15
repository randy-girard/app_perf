module AppPerf
  module Monitor
    class Base
      def initialize
        @timer = Time.now
        reset
      end

      def active?
        false
      end

      def occurance_type
        :seconds
      end

      def occurance_value
        60.seconds
      end

      def ready?
        if occurance_type.eql?(:seconds)
          Time.now > @timer + occurance_value
        else
          false
        end
      end

      def reset
        @timer = Time.now
      end

      def instrument

      end

      def round_time(t, sec = 1)
        down = t - (t.to_i % sec)
        up = down + sec

        difference_down = t - down
        difference_up = up - t

        if (difference_down < difference_up)
          return down.to_s
        else
          return up.to_s
        end
      end
    end
  end
end
