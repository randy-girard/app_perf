class Application < ActiveRecord::Base
  belongs_to :user
  has_many :raw_data
  has_many :hosts
  has_many :transaction_endpoints
  has_many :transaction_data
  has_many :transaction_sample_data
  has_many :error_data

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
