class Stats::LatencyDistributionService < Stats::BaseService
  def call
    if params[:_layer].present?
      @traces = traces
        .select("spans.id, spans.exclusive_duration AS duration")
        .where("spans.layer_id = ?", params[:_layer])
    end

    Trace
      .with(:trace_cte => traces)
      .from("trace_cte")
      .joins("RIGHT JOIN generate_series(1, 100) g(n) ON width_bucket(trace_cte.duration, 0, (select max(duration) + 1 from trace_cte), 100) = g.n")
      .group("g.n")
      .order("g.n")
      .pluck_to_hash(
        "g.n AS bucket",
        "count(distinct trace_cte.id) AS count",
        "min(trace_cte.duration) AS min_duration",
        "max(trace_cte.duration) AS max_duration"
      ).map {|object|
        {
          name: "p#{object[:bucket]}",
          data: { "#{object[:bucket]}: in #{object[:min_duration].to_f.round(2)} to #{object[:max_duration].to_f.round(2)}ms" => object[:count] }
        }
      }
  end
end
