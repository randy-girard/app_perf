class CreateTransactionSampleData < ActiveRecord::Migration
  def change
    create_table :transaction_sample_data, :force => true do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.references :grouping, index: true, polymorphic: true
      t.references :transaction_endpoint, index: true, foreign_key: true
      t.string :name
      t.datetime :timestamp
      t.string :transaction_id
      t.text :payload
      t.float :duration
      t.float :exclusive_duration
      t.float :db_duration
      t.float :view_duration
      t.float :gc_duration
      t.integer :request_id
      t.integer :parent_id
      t.string :action
      t.string :category
      t.timestamps null: false
    end
  end
end
