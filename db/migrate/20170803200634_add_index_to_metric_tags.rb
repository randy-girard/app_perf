class AddIndexToMetricTags < ActiveRecord::Migration
  def up
    execute "CREATE INDEX idx_metric_data_tags ON metric_data USING GIN (tags jsonb_path_ops);"
  end

  def down
    execute "DROP INDEX idx_metric_data_tags;"
  end
end
