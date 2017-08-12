class DropPayloadColumnsFromSpans < ActiveRecord::Migration
  def change
    remove_column :spans, :action, :string
    remove_column :spans, :controller, :string
    remove_column :spans, :url, :string
    remove_column :spans, :domain, :string
  end
end
