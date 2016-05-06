module AppPerf
  class Config
    attr_accessor :store, :instruments, :notification_exclude_patterns, :path_exclude_patterns, :options

    def initialize
      #self.store = AppPerf::AsyncStore.new
      self.store = AppPerf::Store.new
      self.notification_exclude_patterns = []
      self.path_exclude_patterns = [/system\/metrics/, /system_metrics/]
      self.instruments = [
        AppPerf::Instrument::ActionController.new,
        AppPerf::Instrument::ActionView.new,
        AppPerf::Instrument::ActiveRecord.new,
        AppPerf::Instrument::Rack.new
      ]
    end

    def valid?
      !invalid?
    end

    def invalid?
      store.nil? ||
        instruments.nil? ||
        notification_exclude_patterns.nil? ||
        path_exclude_patterns.nil?
    end

    def errors
      return nil if valid?
      errors = []
      errors << 'store cannot be nil' if store.nil?
      errors << 'instruments cannot be nil' if instruments.nil?
      errors << 'notification_exclude_patterns cannot be nil' if notification_exclude_patterns.nil?
      errors << 'path_exclude_patterns cannot be nil' if path_exclude_patterns.nil?
      errors.join("\n")
    end
  end
end
