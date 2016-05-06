module AppPerf
  class Engine < ::Rails::Engine

    attr_accessor :collector, :smc

    config.system_metrics = AppPerf::Config.new

    #initializer "system_metrics.initialize", :before => "system_metrics.start_subscriber" do |app|
      self.smc = Rails.application.config.system_metrics
      raise ArgumentError.new(smc.errors) if smc.invalid?
      self.collector = AppPerf::Collector.new(smc.store)
    #end

    #initializer "system_metrics.start_subscriber", :before => "system_metrics.add_middleware" do |app|
      ActiveSupport::Notifications.subscribe /^[^!]/ do |*args|
        unless smc.notification_exclude_patterns.any? { |pattern| pattern =~ name }
          process_event AppPerf::NestedEvent.new(*args)
        end
      end
    #end



    #initializer "system_metrics.add_middleware", :before => :load_environment_config do |app|
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

