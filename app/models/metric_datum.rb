class MetricDatum < ActiveRecord::Base
  belongs_to :host
  belongs_to :metric

  serialize :tags, HashSerializer
end
