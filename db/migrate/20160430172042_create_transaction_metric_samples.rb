class CreateTransactionMetricSamples < ActiveRecord::Migration
  def change
    create_table :transaction_metric_samples do |t|
      t.references :application, index: true, foreign_key: true
      t.references :raw_datum, index: true, foreign_key: true
      t.references :transaction, index: true, foreign_key: true
      t.references :transaction_metric, index: true, foreign_key: true
      t.text :backtrace

      t.timestamps null: false
    end
  end
end
