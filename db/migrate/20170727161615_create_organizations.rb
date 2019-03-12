class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :license_key
      t.string :name

      t.timestamps null: false
    end
  end
end
