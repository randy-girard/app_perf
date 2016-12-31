class AddDataRetentionHoursToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :data_retention_hours, :decimal, precision: 6, scale: 1
  end
end
