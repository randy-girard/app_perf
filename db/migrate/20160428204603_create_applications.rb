class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.string :license_key

      t.timestamps null: false
    end
  end
end
