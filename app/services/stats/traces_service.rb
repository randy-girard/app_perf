class Stats::TracesService < Stats::BaseService
  def call
    application
      .traces
      .where(:id => traces)
      .joins("INNER JOIN spans AS root_span ON root_span.uuid = traces.trace_key AND root_span.parent_id IS NULL")
      .order("traces.duration DESC")
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .pluck_to_hash(
        :id,
        :trace_key,
        :duration,
        :timestamp,
        "root_span.payload->>'http.url' AS url"
      )
  end
end
