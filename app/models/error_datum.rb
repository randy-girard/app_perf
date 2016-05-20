class ErrorDatum < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  belongs_to :error_message

  serialize :backtrace
end
