class AddUnitToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :unit, :string
  end
end
