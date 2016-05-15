class TransactionEndpoint < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :transaction_data
  has_many :transaction_sample_data
end
