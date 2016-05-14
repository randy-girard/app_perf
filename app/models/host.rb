class Host < ActiveRecord::Base
  belongs_to :application

  has_many :transaction_data
  has_many :transaction_sample_data
  has_many :error_data
  has_many :raw_data
end
