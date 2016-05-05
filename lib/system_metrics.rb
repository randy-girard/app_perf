module SystemMetrics
  autoload :Collector,      'system_metrics/collector'
  autoload :Config,         'system_metrics/config'
  autoload :Middleware,     'system_metrics/middleware'
  autoload :NestedEvent,    'system_metrics/nested_event'
  autoload :Store,          'system_metrics/store'
  autoload :AsyncStore,     'system_metrics/async_store'
  autoload :Version,        'system_metrics/version'

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
    SystemMetrics.collection_off
    yield if block_given?
  ensure
    SystemMetrics.collection_on if previously_collecting
  end

  module_function :collecting?, :without_collection
end

require 'system_metrics/instrument'
require 'system_metrics/engine'