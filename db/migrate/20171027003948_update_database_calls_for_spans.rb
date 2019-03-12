class UpdateDatabaseCallsForSpans < ActiveRecord::Migration[5.0]
  def change
    rename_column :database_calls, :uuid, :span_id
  end
end
