class Stats::ControllersService < Stats::BaseService
  def call
    time_range, period = Reporter.time_range(params)

    cte = MetricDatum
      .select("metric_data.timestamp")
      .select("metric_data.sum")
      .select("metric_data.count")
      .select("jsonb_object_agg(tags.key, tags.value) AS tags")
      .joins(:tags)
      .where(timestamp: time_range)
      .where(tags: { key: ["controller", "action"]})
      .where("tags.value IS NOT NULL")
      .group("metric_data.timestamp")
      .group("metric_data.sum")
      .group("metric_data.count")
      .group("taggings.uuid")

    return MetricDatum
      .with(cte: cte)
      .from("cte")
      .where("tags->>'controller' IS NOT NULL")
      .where("tags->>'action' IS NOT NULL")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .group("tags->>'controller'")
      .group("tags->>'action'")
      .pluck_to_hash(
        "tags->>'controller' AS controller",
        "tags->>'action' AS action",
        "SUM(count) AS freq",
        "SUM(sum) / SUM(count) AS avg"
      )

    application
      .spans
      .with(:trace_cte => traces)
      .where("spans.trace_id IN (SELECT trace_key FROM trace_cte)")
      .where("length(split_part(spans.operation_name, '#', 1)) > 0")
      .where("length(split_part(spans.operation_name, '#', 2)) > 0")
      .where("spans.trace_id IN (SELECT trace_key FROM trace_cte)")
      .joins(:trace)
      .group("split_part(spans.operation_name, '#', 1), split_part(spans.operation_name, '#', 2)")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .pluck_to_hash(
        "split_part(spans.operation_name, '#', 1) AS controller",
        "split_part(spans.operation_name, '#', 2) as action",
        "COUNT(DISTINCT traces.id) AS freq",
        "SUM(traces.duration) / COUNT(traces.id) AS avg"
      )
  end
end
