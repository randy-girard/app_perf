class User < ActiveRecord::Base
  has_many :applications, :dependent => :destroy

  has_secure_password

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
