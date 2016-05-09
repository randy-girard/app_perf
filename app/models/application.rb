class Application < ActiveRecord::Base
  belongs_to :user
  has_many :raw_data
  has_many :hosts
  has_many :metrics
  has_many :event_data

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
