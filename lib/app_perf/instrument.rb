module AppPerf
  module Instrument
    autoload :Base,               'app_perf/instrument/base'
    autoload :ActionController,   'app_perf/instrument/action_controller'
    autoload :ActionMailer,       'app_perf/instrument/action_mailer'
    autoload :ActionView,         'app_perf/instrument/action_view'
    autoload :ActiveRecord,       'app_perf/instrument/active_record'
    autoload :Rack,               'app_perf/instrument/rack'
    autoload :RubyVm,             'app_perf/instrument/ruby_vm'
    autoload :Memory,             'app_perf/instrument/memory'
    autoload :Errors,             'app_perf/instrument/errors'
  end
end
