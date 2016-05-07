class Metric < ActiveRecord::Base
  has_many :children, :class_name => self.name, :foreign_key => :parent_id
  accepts_nested_attributes_for :children

  belongs_to :application
  belongs_to :host
  belongs_to :parent, :class_name => self.name
  serialize :payload

  after_commit do
    #if parent
    #  self.parent_id = parent.id
    #  self.request_id = parent.request_id
    #else
    #  self.request_id = self.id
    #end
    children.each do |metric|
      metric.application_id = self.application_id
      metric.parent_id = self.id
      metric.request_id = self.request_id || self.id
      metric.save
    end
  end

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
  def parent_of?(metric)
    if new_record?
      start = (started_at - metric.started_at) * 1000.0
      start <= 0 && (start + duration >= metric.duration)
    else
      self.id == metric.parent_id
    end
  end

  def child_of?(metric)
    metric.parent_of?(self)
  end
end
