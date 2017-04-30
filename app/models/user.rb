class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :application_users
  has_many :applications, :through => :application_users, :dependent => :destroy

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
