class CreateRawData < ActiveRecord::Migration
  def change
    create_table :raw_data do |t|
      t.references :application
      t.references :host
      t.string :method
      t.text :body

      t.timestamps null: false
    end
  end
end
