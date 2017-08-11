class AddTagsToMetricData < ActiveRecord::Migration
  def change
    add_column :metric_data, :tags, :jsonb, default: '{}'
  end
end
