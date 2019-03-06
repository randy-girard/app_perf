class MetricDatum < ApplicationRecord
  belongs_to :host
  belongs_to :metric
end
