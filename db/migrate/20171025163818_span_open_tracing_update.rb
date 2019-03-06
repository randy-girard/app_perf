class SpanOpenTracingUpdate < ActiveRecord::Migration[5.0]
  def change
    remove_column :spans, :grouping_id, :integer
    remove_column :spans, :grouping_type, :string
    remove_column :spans, :span_type, :string

    add_column :spans, :parent_id, :string
  end
end
