class CreateTraces < ActiveRecord::Migration
  def change
    create_table :traces do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.string :trace_key
      t.datetime :timestamp
      t.float :duration

      t.timestamps null: false
    end

    add_index :traces, [:trace_key, :application_id], :unique => true
  end
end
