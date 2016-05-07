class Host < ActiveRecord::Base
  belongs_to :application

  has_many :metrics
  has_many :raw_data
end
