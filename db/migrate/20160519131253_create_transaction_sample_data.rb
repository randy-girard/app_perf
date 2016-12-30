class CreateTransactionSampleData < ActiveRecord::Migration
  def change
    create_table :transaction_sample_data, :force => true do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.references :grouping, index: true, type: :uuid, polymorphic: true
      t.references :layer, index: true, foreign_key: true
      t.references :transaction_endpoint, index: true, foreign_key: true
      t.references :trace, index: true, foreign_key: true
      t.string :sample_type, :default => "web"
      t.string :name
      t.datetime :timestamp
      t.text :payload
      t.float :duration
      t.float :exclusive_duration
      t.string :trace_key
      t.string :request_id
      t.string :parent_id
      t.string :category
      t.string :url
      t.string :domain
      t.string :controller
      t.string :action
      t.timestamps null: false
    end
  end
end
