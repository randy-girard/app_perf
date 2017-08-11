class DataRetentionJanitor
  def perform(application_id)
    application = Application.find_by_id(application_id)

    if application && application.data_retention_hours.present?
      delete_time = Time.now - application.data_retention_hours.hours

      application.spans.where("timestamp < ?", delete_time).delete_all
      application.database_calls.where("timestamp < ?", delete_time).delete_all
      application.traces.where("timestamp < ?", delete_time).delete_all
      MetricDatum.where("metric_id IN (?) AND timestamp < ?", application.metric_ids, delete_time).delete_all
      application.events.delete_all

      application.error_data.where("created_at < ?", delete_time).delete_all
      application.error_messages.where("created_at < ?", delete_time).delete_all
    end
  end
end
