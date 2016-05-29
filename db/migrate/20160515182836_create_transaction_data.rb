class CreateTransactionData < ActiveRecord::Migration
  def change
    create_table :transaction_data do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.references :transaction_endpoint, index: true, foreign_key: true
      t.datetime :timestamp
      t.integer :call_count
      t.float :duration
      t.float :avg
      t.float :min
      t.float :max
      t.float :sum_sqr
      t.integer :middleware_call_count
      t.float :middleware_duration
      t.integer :app_call_count
      t.float :app_duration
      t.integer :view_call_count
      t.float :view_duration
      t.integer :db_call_count
      t.float :db_duration
      t.integer :gc_call_count
      t.float :gc_duration

      t.timestamps null: false
    end
  end
end
