class RemoveDataRetention < ActiveRecord::Migration[5.0]
  def change
    remove_column :applications, :data_retention_hours, :integer
  end
end
