class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.datetime :timestamp
      t.string :name
      t.float :value

      t.timestamps null: false
    end
  end
end
