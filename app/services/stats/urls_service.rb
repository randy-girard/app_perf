class Stats::UrlsService < Stats::BaseService
  def call
    time_range, period = Reporter.time_range(params)

    cte = MetricDatum
      .select("metric_data.timestamp")
      .select("metric_data.sum")
      .select("metric_data.count")
      .select("jsonb_object_agg(tags.key, tags.value) AS tags")
      .joins(:tags)
      .where(timestamp: time_range)
      .where(tags: { key: ["address", "url"]})
      .where("tags.value IS NOT NULL")
      .group("metric_data.timestamp")
      .group("metric_data.sum")
      .group("metric_data.count")
      .group("taggings.uuid")

    return MetricDatum
      .with(cte: cte)
      .from("cte")
      .where("tags->>'address' IS NOT NULL")
      .where("tags->>'url' IS NOT NULL")
      .group("tags->>'address'")
      .group("tags->>'url'")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .pluck_to_hash(
        "tags->>'address' AS domain",
        "tags->>'url' AS url",
        "SUM(count) AS freq",
        "SUM(sum) / SUM(count) AS avg"
      )
  end
end
