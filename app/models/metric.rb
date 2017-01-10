class Metric < ActiveRecord::Base
  belongs_to :application
  belongs_to :host
end
