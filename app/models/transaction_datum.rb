class TransactionDatum < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
  belongs_to :parent, :class_name => self.name

  has_many :children, :inverse_of => :parent, :class_name => self.name, :foreign_key => :parent_id

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

  # Returns if the current node is the parent of the given node.
  # If this is a new record, we can use started_at values to detect parenting.
  # However, if it was already saved, we lose microseconds information from
  # timestamps and we must rely solely in id and parent_id information.
  def parent_of?(transaction_datum)
    if new_record?
      start = (started_at - transaction_datum.started_at) * 1000.0
      start <= 0 && (start + duration >= transaction_datum.duration)
    else
      self.id == transaction_datum.parent_id
    end
  end

  def child_of?(transaction_datum)
    transaction_datum.parent_of?(self)
  end
end
