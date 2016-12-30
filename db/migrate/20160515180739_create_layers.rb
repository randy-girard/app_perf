class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.references :application, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end

    add_index :layers, [:name, :application_id], :unique => true
  end
end
