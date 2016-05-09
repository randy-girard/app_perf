module AppPerf
  module Middleware
    autoload :Base,     'app_perf/middleware/base'
    autoload :RubyVm,   'app_perf/middleware/ruby_vm'
  end
end
