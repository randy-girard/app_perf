module AppPerf
  module Instrument

    # Base class for System Metric instruments. The default implementations
    # for the methods in this class are all based on a regular expression
    # that is matched against a pattern. Custom intruments that simply need
    # to match against a notfication name can easily extend this class like:
    #
    #   class SearchInstrument < AppPerf::Instrument::Base
    #     def initialize
    #       super /search$/
    #     end
    #   end
    class Base

      attr_reader :pattern

      # Create an instrument that will match notification names on the given
      # pattern.
      def initialize(pattern)
        @pattern = pattern
      end

      def active?
        false
      end

      def before
      end

      def after
      end

      def instrument(*args)
        ActiveSupport::Notifications.instrument(*args)
      end

      # Holds the mapped paths used in prunning.
      def mapped_paths
        @mapped_paths ||= default_mapped_paths
      end

      # Prune paths based on the mapped paths set.
      def prune_path(raw_path)
        mapped_paths.each do |path, replacement|
          next unless path.present?
          raw_path = raw_path.gsub(path, replacement)
        end
        raw_path
      end

      # Declares whether this instrument handles the given event type.
      #
      # Please Note: Even if the instrument would ultimately like to
      # ignore the event, it should still return true if it generally
      # handles events like the one passed.
      def handles?(event)
        (event.name =~ pattern) != nil
      end

      # Indicates whether the given event should be completely ingored
      # and not collected. This is called only if #handles?(event)
      # returns `true`
      def ignore?(event)
        false
      end

      # Provides an opportunity to modify the event before it's collected
      # and stored. This is where you would normally modify the payload
      # to add, remove, or format its elements.
      def prepare(event)
        # Modify the payload if you care to
      end

      private

        def default_mapped_paths
          # Make Rails.root appear as RAILS_ROOT in pruned paths.
          paths = { Rails.root.to_s => 'RAILS_ROOT' }

          # Make Gem paths appear as GEMS_ROOT in pruned paths.
          Gem.path.each do |path|
            paths[File.join(path, "gems")] = "GEMS_ROOT"
          end if defined?(Gem)

          paths
        end

    end
  end
end
