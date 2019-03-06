class RemoveOrganizationFromLayers < ActiveRecord::Migration[5.0]
  def change
    remove_column :layers, :organization_id
  end
end
