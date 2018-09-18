class Stats::LayersService < Stats::BaseService
  def call
    time_range, period = Reporter.time_range(params)

    cte = MetricDatum
      .select("metric_data.sum")
      .select("metric_data.count")
      .select("jsonb_object_agg(tags.key, tags.value) AS tags")
      .joins(:tags)
      .where(timestamp: time_range)
      .where("tags.key = ?", "component")
      .group("metric_data.sum")
      .group("metric_data.count")
      .group("taggings.uuid")

    relation = MetricDatum
      .with(cte: cte)
      .from("cte")
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .group("tags->>'component'")

    if params[:_layer].present?
      relation = relation.where("tags->>'component' = ?", params[:_layer])
    end

    return relation
      .pluck_to_hash(
        "tags->>'component' AS name",
        "SUM(count) AS freq",
        "SUM(sum) / SUM(count) AS avg"
      )
  end
end
