class DatabaseCall < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  belongs_to :database_type

  belongs_to :span, :primary_key => :uuid
end
