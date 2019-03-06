class AddSourceToErrorDatum < ActiveRecord::Migration[5.0]
  def change
    add_column :error_data, :source, :text
  end
end
