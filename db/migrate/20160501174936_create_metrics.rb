class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.references :application, index: true, foreign_key: true
      t.references :raw_datum, index: true, foreign_key: true
      t.string :name
      t.string :scope
      t.datetime :timestamp
      t.float :value
      t.text :raw_data

      t.timestamps null: false
    end
  end
end
