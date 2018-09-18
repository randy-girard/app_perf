class MetricDatum < ActiveRecord::Base
  belongs_to :metric

  has_many :taggings, primary_key: :uuid, foreign_key: :uuid
  has_many :tags, through: :taggings

  after_initialize do |record|
    if record.respond_to?(:uuid)
      record.uuid ||= SecureRandom.uuid.to_s
    end
  end
end
