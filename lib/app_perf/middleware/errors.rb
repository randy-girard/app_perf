module AppPerf
  module Middleware
    class Errors
      def initialize(app, collector, path_exclude_patterns)
        @app = app
        @collector = collector
        @path_exclude_patterns = path_exclude_patterns
      end

      def call(env)
        @app.call(env)
      rescue Exception => e
        handle_exception(env, e)
      end

      protected

      def handle_exception(env, exception)
        notifications.instrument "ruby.error", :path => env["PATH_INFO"], :method => env["REQUEST_METHOD"], :error => exception do
          raise exception
        end
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