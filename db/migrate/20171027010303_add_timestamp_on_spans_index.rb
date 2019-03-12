class AddTimestampOnSpansIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :spans, :timestamp
    add_index :traces, :timestamp
    add_index :database_calls, :timestamp
  end
end
