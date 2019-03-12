class ChangeSpanPayloadTypeToJsonb < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE spans ALTER COLUMN payload TYPE JSONB USING payload::JSONB;"
    execute "CREATE INDEX idx_spans_payload ON spans USING GIN (payload jsonb_path_ops);"
  end

  def down
    execute "ALTER TABLE spans ALTER COLUMN payload TYPE TEXT USING payload::TEXT;"
    execute "DROP INDEX idx_metric_data_tags;"
  end
end
