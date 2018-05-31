class Trace < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :spans, :primary_key => :trace_key
  has_one  :root_span,
    -> { where("spans.parent_id IS NULL") },
    :primary_key => :trace_key,
    :class_name => "Span"

  validates :trace_key, :uniqueness => { :scope => :application_id }

  def arrange_spans(_spans = nil)
    root = nil
    _spans ||= spans.dup.to_a
    _spans.sort! { |a, b| a.end <=> b.end }

    while span = _spans.shift
      if parent = _spans.find { |n| n.parent_of?(span) }
        parent.add_child(span)
      elsif _spans.empty?
        root = span
      end
    end
    root
  end
end
