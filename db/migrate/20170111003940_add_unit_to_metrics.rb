class AddUnitToMetrics < ActiveRecord::Migration[5.0]
  def change
    add_column :metrics, :unit, :string
  end
end
