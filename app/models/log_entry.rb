class LogEntry < ApplicationRecord
  belongs_to :span, :foreign_key => :uuid, optional: true

  attr_accessor :trace_id

  serialize :fields, JSON
end
