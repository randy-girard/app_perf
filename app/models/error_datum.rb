class ErrorDatum < ApplicationRecord
  belongs_to :application, optional: true
  belongs_to :host, optional: true
  belongs_to :error_message, optional: true
  belongs_to :span, :primary_key => :uuid, optional: true

  serialize :source, JSON
  serialize :backtrace, JSON
end
