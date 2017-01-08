class Host < ActiveRecord::Base
  belongs_to :application

  has_many :analytic_event_data
  has_many :traces
  has_many :transaction_sample_data
  has_many :error_data
  has_many :raw_data

  validates :name, :uniqueness => { :scope => :application_id }
end
