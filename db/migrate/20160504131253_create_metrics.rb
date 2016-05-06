class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics, :force => true do |t|
      t.references :application
      t.string :name
      t.datetime :started_at
      t.string :transaction_id
      t.text :payload
      t.float :duration
      t.float :exclusive_duration
      t.integer :request_id
      t.integer :parent_id
      t.string :action
      t.string :category
    end
  end
end
