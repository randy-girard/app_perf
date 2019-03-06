class AddOrganizationToModels < ActiveRecord::Migration[5.0]
  def change
    add_reference :applications, :organization, :index => true
    add_reference :hosts, :organization, :index => true
    add_reference :layers, :organization, :index => true
    add_reference :traces, :organization, :index => true
    add_reference :database_types, :organization, :index => true
    add_reference :error_messages, :organization, :index => true
    add_reference :error_data, :organization, :index => true
    add_reference :transaction_sample_data, :organization, :index => true
    add_reference :database_calls, :organization, :index => true
    add_reference :metrics, :organization, :index => true
    add_reference :events, :organization, :index => true
    add_reference :application_users, :organization, :index => true
  end
end
