class RenameSpanTraceIdToTraceKey < ActiveRecord::Migration[5.2]
  def change
    rename_column :spans, :trace_id, :trace_key
  end
end
