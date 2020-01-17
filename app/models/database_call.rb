class DatabaseCall < ApplicationRecord
  belongs_to :application, optional: true
  belongs_to :host, optional: true
  belongs_to :database_type, optional: true

  belongs_to :span, :primary_key => :uuid, optional: true
end
