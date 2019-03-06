class PercentileReporter < Reporter

  def report_data
    time_range, period = Reporter.time_range(params)

    table = "traces"
    if params[:_layer].present?
      table = "spans"
    end

    relation = application
      .traces
      .joins("LEFT JOIN spans ON traces.trace_key = spans.trace_key")
      .joins("LEFT JOIN spans root_span ON  root_span.trace_key = traces.trace_key AND root_span.parent_id IS NULL")
      .joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")

    case params[:type]
    when "web"
      layer_ids = application.layers.where(name: "Rack").pluck(:id)
      relation = relation.where("root_span.layer_id IN (?)", layer_ids)
    when "worker"
      layer_ids = application.layers.where(name: "Sidekiq").pluck(:id)
      relation = relation.where("root_span.layer_id IN (?)", layer_ids)
    end

    # relation = relation.where("spans.span_type = ?", "web") if params[:_layer].nil?

    if params[:_domain]
      domains = relation.where("spans.payload->>'peer.address' = ?", params[:_domain])
      relation = relation.where(:traces => { :trace_key => domains.select(:trace_key) })
    end
    if params[:_url]
      urls = relation.where("spans.payload->>'http.url' = ?", params[:_url])
      relation = relation.where(:traces => { :trace_key => urls.select(:trace_key) })
    end
    if params[:_controller]
      controllers = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller])
      relation = relation.where(:traces => { :trace_key => controllers.select(:trace_key) })
    end
    if params[:_action]
      actions = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action])
      relation = relation.where(:traces => { :trace_key => actions.select(:trace_key) })
    end
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]

    data = relation
      .group_by_period(*report_params)
      .calculate_all(
        :perc_50 => "percentile_disc(0.50) within group (order by #{table}.duration)",
        :perc_75 => "percentile_disc(0.75) within group (order by #{table}.duration)",
        :perc_90 => "percentile_disc(0.90) within group (order by #{table}.duration)",
        :perc_95 => "percentile_disc(0.95) within group (order by #{table}.duration)",
        :perc_99 => "percentile_disc(0.99) within group (order by #{table}.duration)"
      )

    latencies = {
      :perc_50 => {},
      :perc_75 => {},
      :perc_90 => {},
      :perc_95 => {},
      :perc_99 => {}
    }

    data.each_pair do |timestamp, percentiles|
      latencies[:perc_50][timestamp] = percentiles.is_a?(Hash) ? percentiles[:perc_50] : percentiles
      latencies[:perc_75][timestamp] = percentiles.is_a?(Hash) ? percentiles[:perc_75] : percentiles
      latencies[:perc_90][timestamp] = percentiles.is_a?(Hash) ? percentiles[:perc_90] : percentiles
      latencies[:perc_95][timestamp] = percentiles.is_a?(Hash) ? percentiles[:perc_95] : percentiles
      latencies[:perc_99][timestamp] = percentiles.is_a?(Hash) ? percentiles[:perc_99] : percentiles
    end

    gradient = Gradient.new(colors: ["#0082c7", "#d41121"], steps: 5)
    colors = gradient.hex

    [
      {:name => "99th Percentile", :data => latencies[:perc_99], :color => colors[4] },
      {:name => "95th Percentile", :data => latencies[:perc_95], :color => colors[3] },
      {:name => "90th Percentile", :data => latencies[:perc_90], :color => colors[2] },
      {:name => "75th Percentile", :data => latencies[:perc_75], :color => colors[1] },
      {:name => "50th Percentile", :data => latencies[:perc_50], :color => colors[0] }
    ]
  end
end
