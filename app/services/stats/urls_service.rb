class Stats::UrlsService < Stats::BaseService
  def call
    application
      .spans
      .with(:trace_cte => traces)
      .where("spans.trace_id IN (SELECT trace_key FROM trace_cte)")
      .where("spans.payload->>'peer.address' IS NOT NULL AND spans.payload->>'http.url' IS NOT NULL")
      .joins(:trace)
      .group("spans.payload->>'peer.address', spans.payload->>'http.url'")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .pluck_to_hash(
        "spans.payload->>'peer.address' AS domain",
        "spans.payload->>'http.url' AS url",
        "COUNT(DISTINCT traces.id) AS freq",
        "SUM(traces.duration) / COUNT(traces.id) AS avg"
      )
  end
end
