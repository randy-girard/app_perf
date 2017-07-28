class AddDataTypeToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :data_type, :string, :default => "custom"
  end
end
