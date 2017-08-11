class DatabaseCall < ActiveRecord::Base
  belongs_to :organization
  belongs_to :application
  belongs_to :host
  belongs_to :database_type

  has_one :database_span, :as => :grouping, :primary_key => :uuid, :class_name => "Span"
end
