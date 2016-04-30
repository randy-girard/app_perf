class CreateTransactionMetrics < ActiveRecord::Migration
  def change
    create_table :transaction_metrics do |t|
      t.references :transaction
      t.references :application
      t.string :name
      t.datetime :timestamp
      t.boolean :error
      t.float :duration
      t.float :database_duration
      t.integer :database_count
      t.float :gc_duration
      t.string :method
      t.integer :code

      t.timestamps null: false
    end
  end
end
