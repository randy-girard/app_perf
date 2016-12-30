class Trace < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :transaction_sample_data

  validates :trace_key, :uniqueness => { :scope => :application_id }

  has_one :root_sample,
    -> { where(:parent_id => nil) },
    :class_name => "TransactionSampleDatum"
end
