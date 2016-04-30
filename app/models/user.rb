class User < ActiveRecord::Base
  has_many :applications

  has_secure_password

end
