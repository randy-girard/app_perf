class AddSpansParentIdIndex < ActiveRecord::Migration
  def change
    add_index :spans, :parent_id
  end
end
