class Stats::HostsService < Stats::BaseService
  def call
    Host
      .with(:trace_cte => traces)
      .joins(:spans => :trace)
      .where("spans.trace_id IN (SELECT trace_key FROM trace_cte)")
      .where("hosts.name IS NOT NULL")
      .group("hosts.id, hosts.name")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
      .pluck_to_hash(
        "hosts.id AS id",
        "hosts.name AS name",
        "COUNT(DISTINCT traces.id) AS freq",
        "SUM(traces.duration) / COUNT(traces.id) AS avg"
      )
  end
end
