class RemoveColumnsFromMetrics < ActiveRecord::Migration[5.0]
  def change
    remove_column :metrics, :label
    remove_column :metrics, :data_type
  end
end
