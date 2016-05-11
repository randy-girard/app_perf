module AppPerf
  module Middleware
    class RubyVm
      def initialize(app, collector, path_exclude_patterns)
        @app = app
        @collector = collector
        @path_exclude_patterns = path_exclude_patterns
      end

      def call(env)
        GC::Profiler.clear

        if exclude_path? env["PATH_INFO"]
          @app.call(env)
        else
          @collector.collect do
            response = notifications.instrument "ruby_vm.gc", :path => env["PATH_INFO"], :method => env["REQUEST_METHOD"] do
              @app.call(env)
            end
          end
        end
      end

    protected

      def exclude_path?(path)
        @path_exclude_patterns.any? { |pattern| pattern =~ path }
      end

      def notifications
        ActiveSupport::Notifications
      end
    end
  end
end