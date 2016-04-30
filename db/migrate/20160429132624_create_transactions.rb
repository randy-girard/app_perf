class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :application, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
