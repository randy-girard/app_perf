class TransactionMetricSample < ActiveRecord::Base
  belongs_to :application
  belongs_to :parent, :class_name => "Transaction", :foreign_key => :transaction_id
  belongs_to :transaction_metric

  serialize :backtrace
end
