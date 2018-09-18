class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :key
      t.string :value

      t.timestamps null: false
    end

    add_index :tags, [:key, :value]
  end
end
