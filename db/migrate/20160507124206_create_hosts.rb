class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.references :application, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end

    add_index :hosts, [:name, :application_id], :unique => true
  end
end
