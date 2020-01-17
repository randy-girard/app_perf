class MetricDatum < ApplicationRecord
  belongs_to :host, optional: true
  belongs_to :metric, optional: true
end
