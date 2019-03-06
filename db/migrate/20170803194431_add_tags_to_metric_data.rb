class AddTagsToMetricData < ActiveRecord::Migration[5.0]
  def change
    add_column :metric_data, :tags, :jsonb, default: '{}'
  end
end
