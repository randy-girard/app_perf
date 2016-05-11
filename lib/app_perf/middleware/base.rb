module AppPerf
  module Middleware
    class Base
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
            begin
              response = notifications.instrument "request.rack", :path => env["PATH_INFO"], :method => env["REQUEST_METHOD"] do
                @app.call(env)
              end
              notifications.instrument "ruby.memory"
              notifications.instrument "ruby_vm.gc"
            rescue Exception => e
              handle_exception(env, e)
            end
            response
          end
        end
      end

      protected

      def handle_exception(env, exception)
        notifications.instrument "ruby.error", :path => env["PATH_INFO"], :method => env["REQUEST_METHOD"], :error => exception
        raise exception
      end

      def exclude_path?(path)
        @path_exclude_patterns.any? { |pattern| pattern =~ path }
      end

      def notifications
        ActiveSupport::Notifications
      end
    end
  end
end