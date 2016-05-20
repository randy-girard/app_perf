class Application < ActiveRecord::Base
  belongs_to :user
  has_many :raw_data
  has_many :hosts
  has_many :analytic_event_data
  has_many :transaction_endpoints
  has_many :transaction_data
  has_many :transaction_sample_data
  has_many :error_messages
  has_many :error_data
  has_many :database_types
  has_many :database_calls

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
