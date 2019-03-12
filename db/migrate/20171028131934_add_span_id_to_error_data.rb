class AddSpanIdToErrorData < ActiveRecord::Migration[5.0]
  def change
    add_column :error_data, :span_id, :string
  end
end
