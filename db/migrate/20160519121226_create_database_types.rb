class CreateDatabaseTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :database_types do |t|
      t.references :application, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
