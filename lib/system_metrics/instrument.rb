module SystemMetrics
  module Instrument
    autoload :Base,               'system_metrics/instrument/base'
    autoload :ActionController,   'system_metrics/instrument/action_controller'
    autoload :ActionMailer,       'system_metrics/instrument/action_mailer'
    autoload :ActionView,         'system_metrics/instrument/action_view'
    autoload :ActiveRecord,       'system_metrics/instrument/active_record'
    autoload :Rack,               'system_metrics/instrument/rack'
  end
end
