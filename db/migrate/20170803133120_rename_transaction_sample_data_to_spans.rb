class RenameTransactionSampleDataToSpans < ActiveRecord::Migration
  def change
    rename_column :transaction_sample_data, :sample_type, :span_type
    rename_table :transaction_sample_data, :spans
  end
end
