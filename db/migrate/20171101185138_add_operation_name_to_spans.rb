class AddOperationNameToSpans < ActiveRecord::Migration[5.0]
  def change
    add_column :spans, :operation_name, :string
  end
end
