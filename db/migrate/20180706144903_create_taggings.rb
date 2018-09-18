class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, index: true
      t.string :uuid, index: true

      t.timestamps null: false
    end
  end
end
