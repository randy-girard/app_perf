class RemoveSpanTraceId < ActiveRecord::Migration[5.2]
  def change
    remove_column :spans, :trace_id
    add_index :spans, :trace_key
  end
end
