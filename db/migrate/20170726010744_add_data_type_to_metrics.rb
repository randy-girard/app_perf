class AddDataTypeToMetrics < ActiveRecord::Migration[5.0]
  def change
    add_column :metrics, :data_type, :string, :default => "custom"
  end
end
