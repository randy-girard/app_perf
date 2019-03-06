class RemoveApplicationIdFromHosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :hosts, :application_id
  end
end
