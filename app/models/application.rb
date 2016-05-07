class Application < ActiveRecord::Base
  belongs_to :user
  has_many :raw_data
  has_many :hosts
  has_many :metrics

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
