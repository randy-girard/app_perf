class CreateApplicationUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :application_users do |t|
      t.references :application, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
