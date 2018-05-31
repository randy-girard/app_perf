class Span < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :application
  belongs_to :host
  belongs_to :grouping, :primary_key => :uuid, :polymorphic => true
  belongs_to :layer
  belongs_to :trace, :primary_key => :trace_key

  belongs_to :parent, :primary_key => :uuid, :class_name => "Span"
  has_many :children, :primary_key => :uuid, :foreign_key => :parent_id, :class_name => "Span"

  has_many :log_entries, :primary_key => :uuid

  has_one :database_call, :primary_key => :uuid
  has_one :backtrace, :as => :backtraceable, :primary_key => :uuid
  has_one :error, :primary_key => :uuid, :class_name => "ErrorDatum"

  delegate :name, :to => :layer, :prefix => true

  serialize :payload, HashSerializer

  def tags
    payload
  end

  def has_error?
    tag("error") == true
  end

  def tag(key)
    if payload.is_a?(Hash)
      payload[key.to_s]
    else
      nil
    end
  end

  def source
    @log_entry ||= log_entries.where(:event => "source").first || LogEntry.new
    @log_entry.fields.fetch("stack", nil) || @log_entry.fields.fetch(":stack", nil)
  end

  def is_root?
    parent_id == nil
  end

  def is_query?(uuid)
    grouping_type.eql?("DatabaseCall") &&
    grouping_id.to_s.eql?(uuid)
  end

  def end
    timestamp.to_f + duration.to_f
  end

  def exclusive_duration
    duration - children.inject(0.0) { |sum, child| sum + child.duration }
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

  def send_chain(arr)
    Array(arr).inject({}) { |o, a| o.merge(a => self.send(a)) }
  end

  def dump_attribute_tree(attributes = [:id])
    if children.present?
      [
        self.send_chain(attributes),
        :children => children.map {|c|
          c.dump_attribute_tree(attributes)
        }.flatten
      ]
    else
      [self.send_chain(attributes)]
    end
  end

  # Returns if the current node is the parent of the given node.
  # If this is a new record, we can use started_at values to detect parenting.
  # However, if it was already saved, we lose microseconds information from
  # timestamps and we must rely solely in id and parent_id information.
  def parent_of?(span)
    start = (timestamp - span.timestamp) * 1000.0
    start <= 0 && (start + duration >= span.duration)
  end

  def child_of?(span)
    span.parent_of?(self)
  end
end
