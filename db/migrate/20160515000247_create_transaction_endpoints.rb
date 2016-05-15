class CreateTransactionEndpoints < ActiveRecord::Migration
  def change
    create_table :transaction_endpoints do |t|
      t.references :application, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
