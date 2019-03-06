class RenameTransactionSampleDataToSpans < ActiveRecord::Migration[5.0]
  def change
    rename_column :transaction_sample_data, :sample_type, :span_type
    rename_table :transaction_sample_data, :spans
  end
end
