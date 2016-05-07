module AppPerf
  class Engine < ::Rails::Engine

    attr_accessor :collector, :smc

    config.app_perf = AppPerf::Config.new

    #initializer "app_perf.initialize", :before => "app_perf.start_subscriber" do |app|
      self.smc = Rails.application.config.app_perf
      raise ArgumentError.new(smc.errors) if smc.invalid?
      self.collector = AppPerf::Collector.new(smc.store)
    #end

    #initializer "app_perf.start_subscriber", :before => "app_perf.add_middleware" do |app|
      ActiveSupport::Notifications.subscribe /^[^!]/ do |*args|
        unless smc.notification_exclude_patterns.any? { |pattern| pattern =~ name }
          process_event AppPerf::NestedEvent.new(*args)
        end
      end
    #end

    #initializer "app_perf.add_middleware", :before => :load_environment_config do |app|
      Rails.application.config.middleware.use AppPerf::Middleware, collector, smc.path_exclude_patterns
    #end

    def process_event(event)
      instrument = smc.instruments.find { |instrument| instrument.handles?(event) }
      if instrument.present?
        unless instrument.ignore?(event)
          instrument.prepare(event)
          collector.collect_event(event)
        end
      else
        collector.collect_event(event)
      end
    end
  end
end

