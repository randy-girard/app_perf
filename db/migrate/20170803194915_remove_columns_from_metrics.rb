class RemoveColumnsFromMetrics < ActiveRecord::Migration
  def change
    remove_column :metrics, :label
    remove_column :metrics, :data_type
  end
end
