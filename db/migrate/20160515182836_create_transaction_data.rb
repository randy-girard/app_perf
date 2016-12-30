class CreateTransactionData < ActiveRecord::Migration
  def change
    create_table :transaction_data do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.references :transaction_endpoint, index: true, foreign_key: true
      t.references :layer, index: true, foreign_key: true
      t.datetime :timestamp
      t.integer :call_count
      t.float :duration
      t.float :avg
      t.float :min
      t.float :max
      t.float :sum_sqr
      t.timestamps null: false
    end
  end
end
