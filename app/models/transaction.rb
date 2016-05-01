class Transaction < ActiveRecord::Base
  belongs_to :application
  belongs_to :raw_datum
  has_many :transaction_metrics
  has_many :transaction_metric_samples
end
