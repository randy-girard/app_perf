class Trace < ActiveRecord::Base
  belongs_to :organization
  belongs_to :application
  belongs_to :host

  has_many :spans

  validates :trace_key, :uniqueness => { :scope => :application_id }

  def root_span
    spans.order(:timestamp).first
  end

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
