class CreateErrorMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :error_messages do |t|
      t.references :application, index: true, foreign_key: true
      t.string :fingerprint
      t.string :error_class
      t.string :error_message
      t.datetime :last_error_at

      t.timestamps null: false
    end
  end
end
