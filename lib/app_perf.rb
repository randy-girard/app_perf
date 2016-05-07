require 'socket'

module AppPerf
  autoload :Collector,      'app_perf/collector'
  autoload :Config,         'app_perf/config'
  autoload :Middleware,     'app_perf/middleware'
  autoload :NestedEvent,    'app_perf/nested_event'
  autoload :Store,          'app_perf/store'
  autoload :AsyncStore,     'app_perf/async_store'
  autoload :Version,        'app_perf/version'

  def self.config
    @config ||= YAML.load_file(Rails.root.join("app_perf.yml"))[Rails.env]
  end

  def self.host
    @host ||= Socket.gethostname
  end

  def self.collection_on
    Thread.current[:system_metrics_collecting] = true
  end

  def self.collection_off
    Thread.current[:system_metrics_collecting] = false
  end

  def collecting?
    Thread.current[:system_metrics_collecting] || false
  end

  def without_collection
    previously_collecting = collecting?
    AppPerf.collection_off
    yield if block_given?
  ensure
    AppPerf.collection_on if previously_collecting
  end

  module_function :collecting?, :without_collection
end

require 'app_perf/instrument'
require 'app_perf/engine'