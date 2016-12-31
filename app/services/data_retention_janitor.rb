class DataRetentionJanitor
  def perform(application_id)
    application = Application.find(application_id)

    if application && application.data_retention_hours.present?
      delete_time = Time.now - application.data_retention_hours.hours

      application.traces.where("timestamp < ?", delete_time).delete_all
      application.transaction_sample_data.where("timestamp < ?", delete_time).delete_all
      application.error_messages.where("created_at < ?", delete_time).delete_all
      application.error_data.where("created_at < ?", delete_time).delete_all
      application.database_calls.where("timestamp < ?", delete_time).delete_all
      application.analytic_event_data.where("timestamp < ?", delete_time).delete_all
    end
  end
end
