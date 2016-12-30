class CreateBacktraces < ActiveRecord::Migration
  def change
    create_table :backtraces do |t|
      t.references :backtraceable, polymorphic: true, type: :string, index: true
      t.text :backtrace

      t.timestamps null: false
    end
  end
end
