class TransactionSampleDatum < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  #belongs_to :parent, :class_name => self.name, :foreign_key => :request_id
  belongs_to :transaction_endpoint
  belongs_to :grouping, :primary_key => :uuid, :polymorphic => true
  has_one :database_call, :foreign_key => :uuid, :primary_key => :grouping_id
  belongs_to :layer
  belongs_to :trace

  has_one :backtrace, :as => :backtraceable, :primary_key => :trace_key

  delegate :name, :to => :layer, :prefix => true

  def is_sql(uuid)
    grouping_type.eql?("DatabaseCall") &&
    grouping_id.to_s.eql?(uuid)
  end

  def end
    timestamp + duration
  end

  attr_accessor :parent, :children
  def add_child(child)
    child.parent = self
    self.children ||= []
    self.children << child
  end

  def children
    @children ||= []
  end

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

  def send_chain(arr)
    Array(arr).inject(self) { |o, a| o.send(*a) }
  end

  def dump_attribute_tree(attribute = :id)
    if children.present?
      [
        self.send_chain(attribute),
        :children => children.map {|c|
          c.dump_attribute_tree(attribute)
        }.flatten
      ]
    else
      [self.send_chain(attribute)]
    end
  end

  # Returns if the current node is the parent of the given node.
  # If this is a new record, we can use started_at values to detect parenting.
  # However, if it was already saved, we lose microseconds information from
  # timestamps and we must rely solely in id and parent_id information.
  def parent_of?(sample)
    start = (timestamp - sample.timestamp) * 1000.0
    start <= 0 && (start + duration >= sample.duration)
  end

  def child_of?(sample)
    sample.parent_of?(self)
  end
end
