module AppPerf
  module Middleware
    autoload :Base,     'app_perf/middleware/base'
    autoload :RubyVm,   'app_perf/middleware/ruby_vm'
    autoload :Memory,   'app_perf/middleware/memory'
    autoload :Errors,   'app_perf/middleware/errors'
  end
end
