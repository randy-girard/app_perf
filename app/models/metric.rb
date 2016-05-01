class Metric < ActiveRecord::Base
  belongs_to :application
  belongs_to :raw_datum

  serialize :raw_data
end
