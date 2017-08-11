class Organization < ActiveRecord::Base
  belongs_to :user

  has_many :applications, :dependent => :delete_all

  has_many :metrics
  has_many :database_calls
  has_many :spans
  has_many :error_data
  has_many :error_messages
  has_many :database_types
  has_many :traces
  has_many :layers
  has_many :hosts, :dependent => :delete_all
  has_many :deployments

  has_many :organization_users, :dependent => :delete_all
  has_many :users, :through => :organization_users

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end
end
