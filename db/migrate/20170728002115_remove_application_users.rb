class RemoveApplicationUsers < ActiveRecord::Migration[5.0]
  def change
    drop_table :application_users
  end
end
