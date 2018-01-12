class Stats::ControllersService < Stats::BaseService
  def call
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
