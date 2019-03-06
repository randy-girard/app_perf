class DurationReporter < Reporter
  def report_data
    time_range, period = Reporter.time_range(params)

    relation = application
      .layers
      .joins("LEFT JOIN spans ON spans.layer_id = layers.id")
      .joins("LEFT JOIN traces ON spans.trace_key = traces.trace_key")
      .joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")

    case params[:type]
    when "web"
      layer_ids = application.layers.where(name: "Rack").pluck(:id)
      relation = relation.joins("JOIN spans root_span ON  root_span.trace_key = traces.trace_key AND root_span.parent_id IS NULL")
      relation = relation.where("root_span.layer_id IN (?)", layer_ids)
    when "worker"
      layer_ids = application.layers.where(name: "Sidekiq").pluck(:id)
      relation = relation.joins("JOIN spans root_span ON  root_span.trace_key = traces.trace_key AND root_span.parent_id IS NULL")
      relation = relation.where("root_span.layer_id IN (?)", layer_ids)
    end

    if params[:_domain]
      domains = relation.where("spans.payload->>'peer.address' = ?", params[:_domain])
      relation = relation.where(:traces => { :trace_key => domains.select("spans.trace_key") })
    end
    if params[:_url]
      urls = relation.where("spans.payload->>'http.url' = ?", params[:_url])
      relation = relation.where(:traces => { :trace_key => urls.select("spans.trace_key") })
    end
    if params[:_controller]
      controllers = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller])
      relation = relation.where(:traces => { :trace_key => controllers.select("spans.trace_key") })
    end
    if params[:_action]
      actions = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action])
      relation = relation.where(:traces => { :trace_key => actions.select("spans.trace_key") })
    end
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]
    relation = relation.group("layers.name")

    data = relation
      .group_by_period(*report_params)
      .calculate_all("CASE COUNT(DISTINCT spans.trace_key) WHEN 0 THEN 0 ELSE SUM(spans.exclusive_duration) / COUNT(DISTINCT spans.trace_key) END")

    hash = []
    layers = {}
    data.each_pair do |layer, event|
      layers[layer.first] ||= []
      layers[layer.first] << [layer.second, event]
    end

    layers.each_pair do |layer, data|
      hash.push({
        :name => layer,
        :data => data,
        :color => "##{Digest::MD5.hexdigest(layer)[0..5]}",
        :id => "ID-#{layer}"
      }) rescue nil
    end

    hash
  end
end
