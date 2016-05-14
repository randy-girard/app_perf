class CreateTransactionData < ActiveRecord::Migration
  def change
    create_table :transaction_data do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.string :end_point
      t.string :name
      t.datetime :timestamp
      t.integer :call_count
      t.float :duration
      t.integer :db_call_count
      t.float :db_duration
      t.integer :gc_call_count
      t.float :gc_duration

      t.timestamps null: false
    end
  end
end
