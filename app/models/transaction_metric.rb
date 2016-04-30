class TransactionMetric < ActiveRecord::Base
  belongs_to :application
  belongs_to :parent, :class_name => "Transaction"

  has_many :transaction_metric_samples
end
