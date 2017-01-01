class CreateDatabaseCalls < ActiveRecord::Migration
  def change
    create_table :database_calls do |t|
      t.references :application, index: true, foreign_key: true
      t.references :host, index: true, foreign_key: true
      t.references :database_type, index: true, foreign_key: true
      t.references :layer, index: true, foreign_key: true
      t.string :uuid, index: true
      t.string :statement
      t.datetime :timestamp
      t.float :duration

      t.timestamps null: false
    end
  end
end
