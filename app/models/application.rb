class Application < ActiveRecord::Base
  belongs_to :user
  has_many :metrics, :dependent => :delete_all
  has_many :metric_data
  has_many :database_calls, :dependent => :delete_all
  has_many :spans, :dependent => :delete_all
  has_many :error_data, :dependent => :delete_all
  has_many :error_messages, :dependent => :delete_all
  has_many :database_types, :dependent => :delete_all
  has_many :traces, :dependent => :delete_all
  has_many :layers, :dependent => :delete_all

  has_many :events, :dependent => :delete_all
  has_many :deployments

  validates :name, presence: true

  before_validation do |record|
    record.license_key ||= SecureRandom.uuid
  end

  def test
    y caller(0)
  end
end
