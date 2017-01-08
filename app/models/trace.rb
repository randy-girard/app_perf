class Trace < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :transaction_sample_data

  validates :trace_key, :uniqueness => { :scope => :application_id }

  def root_sample
    transaction_sample_data.order(:timestamp).first
  end

  def arrange_samples(samples = nil)
    root = nil
    samples ||= transaction_sample_data.dup.to_a
    samples.sort! { |a, b| a.end <=> b.end }

    while sample = samples.shift
      if parent = samples.find { |n| n.parent_of?(sample) }
        parent.add_child(sample)
      elsif samples.empty?
        root = sample
      end
    end
    root
  end
end
