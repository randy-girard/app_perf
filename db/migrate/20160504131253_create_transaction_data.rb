class CreateTransactionData < ActiveRecord::Migration
  def change
    create_table :transaction_data, :force => true do |t|
      t.references :application
      t.references :host
      t.string :end_point
      t.string :name
      t.datetime :started_at
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
