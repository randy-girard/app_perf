class CreateOrganizationUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :organization_users do |t|
      t.references :organization, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
