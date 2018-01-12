class Stats::LayersService < Stats::BaseService
  def call
    orders = {
      "Freq" => "COUNT(DISTINCT spans.uuid) DESC",
      "Avg" => "(SUM(spans.exclusive_duration) / COUNT(DISTINCT spans.uuid)) DESC",
      "FreqAvg" => "(COUNT(DISTINCT spans.id) * SUM(spans.exclusive_duration) / COUNT(DISTINCT spans.uuid)) DESC"
    }

    layers = application
      .layers
      .with(:trace_cte => traces)
      .joins(:spans)
      .where("spans.trace_id IN (SELECT trace_key FROM trace_cte)")
      .order(orders[params[:_order]] || orders["FreqAvg"])
      .group("layers.id, layers.name")
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])

    if params[:_layer].present?
      layers = layers.where("spans.layer_id = ?", params[:_layer])
    end

    layers
      .pluck_to_hash(
        "layers.id AS id",
        "layers.name AS name",
        "COUNT(DISTINCT spans.uuid) AS freq",
        "SUM(spans.exclusive_duration) / COUNT(DISTINCT spans.uuid) AS avg"
      )
  end
end
