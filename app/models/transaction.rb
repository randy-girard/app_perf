class Transaction < ActiveRecord::Base
  belongs_to :application
  has_many :transaction_metrics
  has_many :transaction_metric_samples
end
