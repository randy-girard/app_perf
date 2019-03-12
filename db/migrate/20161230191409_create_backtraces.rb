class CreateBacktraces < ActiveRecord::Migration[5.0]
  def change
    create_table :backtraces do |t|
      t.references :backtraceable, polymorphic: true, type: :string, index: true
      t.text :backtrace

      t.timestamps null: false
    end
  end
end
