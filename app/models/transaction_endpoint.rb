class TransactionEndpoint < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :database_calls
  has_many :transaction_data
  has_many :transaction_sample_data
  has_many :root_transaction_sample_data, -> { where(:parent_id => nil) }, :class_name => "TransactionSampleDatum"
end
