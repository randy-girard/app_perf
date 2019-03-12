class AddSpansParentIdIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :spans, :parent_id
  end
end
