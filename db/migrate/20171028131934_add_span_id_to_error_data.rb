class AddSpanIdToErrorData < ActiveRecord::Migration
  def change
    add_column :error_data, :span_id, :string
  end
end
