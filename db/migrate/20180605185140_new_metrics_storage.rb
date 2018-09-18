class NewMetricsStorage < ActiveRecord::Migration
  def change
    drop_table :metric_data
    drop_table :metrics

    create_table :metrics do |t|
      t.references :application
      t.string :name
    end

    create_table :metric_data, id: false do |t|
      t.string :uuid, :string, null: false, unique: true, index: true
      t.references :metric, index: true
      t.references :metric_tag, index: true
      t.timestamp :timestamp
      t.integer :count
      t.decimal :sum
      t.text :histogram, :jsonb, default: []
    end
  end
end
