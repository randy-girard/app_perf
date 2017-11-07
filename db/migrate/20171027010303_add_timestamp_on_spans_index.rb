class AddTimestampOnSpansIndex < ActiveRecord::Migration
  def change
    add_index :spans, :timestamp
    add_index :traces, :timestamp
    add_index :database_calls, :timestamp
  end
end
