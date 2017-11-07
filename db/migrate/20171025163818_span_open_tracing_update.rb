class SpanOpenTracingUpdate < ActiveRecord::Migration
  def change
    remove_column :spans, :grouping_id, :integer
    remove_column :spans, :grouping_type, :string
    remove_column :spans, :trace_key, :string
    remove_column :spans, :span_type, :string

    add_column :spans, :parent_id, :string

    reversible do |dir|
      dir.up  {
        remove_foreign_key :spans, :trace
        change_column :spans, :trace_id, :string
      }
      dir.down {
        add_foreign_key :spans, :trace
        change_column :spans, :trace_id, :integer
      }
    end
  end
end
