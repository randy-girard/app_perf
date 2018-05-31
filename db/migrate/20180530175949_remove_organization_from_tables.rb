class RemoveOrganizationFromTables < ActiveRecord::Migration
  def change
    tables = %w(
      applications
      database_calls
      database_types
      error_data
      error_messages
      events
      hosts
      metrics
      spans
      traces
    )

    tables.each do |table|
      remove_column table, :organization_id
    end

    drop_table :organizations, force: :cascade
    drop_table :organization_users, force: :cascade
  end
end
