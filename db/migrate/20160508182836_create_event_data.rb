class CreateEventData < ActiveRecord::Migration
  def change
    create_table :event_data do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.integer :transaction_id
      t.string :name
      t.datetime :timestamp
      t.integer :num
      t.float :value
      t.float :avg

      t.timestamps null: false
    end
  end
end
