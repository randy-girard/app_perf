class FixUpMetrics < ActiveRecord::Migration[5.0]
  def change
    remove_column :metrics, :unit, :string
    remove_column :metrics, :timestamp, :datetime
    remove_column :metrics, :value, :float
    remove_column :metrics, :host_id, :integer

    add_column :metrics, :label, :string

    create_table :metric_data do |t|
      t.references :host, index: true, foreign_key: true
      t.references :metric, index: true, foreign_key: true
      t.datetime :timestamp
      t.float :value
    end
  end
end
