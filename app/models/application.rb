class Application < ActiveRecord::Base
  belongs_to :user

  has_many :transactions
  has_many :transaction_metrics
  has_many :transaction_metric_samples
  has_many :raw_data

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
