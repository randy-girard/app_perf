class DatabaseCall < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  belongs_to :database_type
  belongs_to :transaction_endpoint

  has_many :database_samples, :as => :grouping, :class_name => "TransactionSampleDatum"
end
