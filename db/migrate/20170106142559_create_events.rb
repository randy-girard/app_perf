class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type
      t.references :application, index: true, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
