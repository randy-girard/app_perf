class CreateLogEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :log_entries do |t|
      t.string :span_id, :index => true
      t.string :event
      t.timestamp :timestamp
      t.text :fields

      t.timestamps null: false
    end
  end
end
