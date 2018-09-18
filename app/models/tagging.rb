class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :metric_datum, primary_key: :uuid, foreign_key: :uuid
end
