class TransactionSampleDatum < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  belongs_to :parent, :class_name => self.name, :foreign_key => :request_id
  belongs_to :transaction_endpoint
  belongs_to :grouping, :primary_key => :uuid, :polymorphic => true
  has_one :database_call, :foreign_key => :uuid, :primary_key => :grouping_id
  belongs_to :layer
  belongs_to :trace

  has_one :backtrace, :as => :backtraceable, :primary_key => :trace_key

  delegate :name, :to => :layer, :prefix => true

  has_many :children,
    -> { where("transaction_sample_data.parent_id IS NOT NULL") },
    :inverse_of => :parent,
    :class_name => self.name,
    :primary_key => :request_id,
    :foreign_key => :parent_id

  serialize :payload

  def ancestors
    ancestors = []
    metric = self
    while parent = metric.parent
      ancestors << parent
      metric = parent
    end
    ancestors
  end

  def dump_attribute_tree(attribute = :id)
    if children.present?
      [
        self.send(attribute),
        :children => children.map {|c|
          c.dump_attribute_tree(attribute)
        }.flatten
      ]
    else
      [self.send(attribute)]
    end
  end

  # Returns if the current node is the parent of the given node.
  # If this is a new record, we can use started_at values to detect parenting.
  # However, if it was already saved, we lose microseconds information from
  # timestamps and we must rely solely in id and parent_id information.
  def parent_of?(transaction_sample_datum)
    if new_record?
      start = (started_at - transaction_sample_datum.started_at) * 1000.0
      start <= 0 && (start + duration >= transaction_sample_datum.duration)
    else
      self.request_id == transaction_sample_datum.parent_id
    end
  end

  def child_of?(transaction_sample_datum)
    transaction_sample_datum.parent_of?(self)
  end
end
