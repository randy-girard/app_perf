class Host < ActiveRecord::Base
  belongs_to :organization
  belongs_to :application

  has_many :metric_data
  has_many :traces
  has_many :transaction_sample_data
  has_many :error_data
  has_many :raw_data

  validates :name, :uniqueness => { :scope => :organization_id }
end
