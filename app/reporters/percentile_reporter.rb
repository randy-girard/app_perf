class PercentileReporter < Reporter

  def report_data
    time_range, period = Reporter.time_range(params)

    table = "traces"
    if params[:_layer].present?
      table = "spans"
    end

    relation = application
      .traces
      .joins("LEFT JOIN spans ON traces.trace_key = spans.trace_id")
      .joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")

    # relation = relation.where("spans.span_type = ?", "web") if params[:_layer].nil?

    if params[:_domain]
      domains = relation.where("spans.payload->>'peer.address' = ?", params[:_domain])
      relation = relation.where(:traces => { :trace_key => domains.select(:trace_id) })
    end
    if params[:_url]
      urls = relation.where("spans.payload->>'http.url' = ?", params[:_url])
      relation = relation.where(:traces => { :trace_key => urls.select(:trace_id) })
    end
    if params[:_controller]
      controllers = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller])
      relation = relation.where(:traces => { :trace_key => controllers.select(:trace_id) })
    end
    if params[:_action]
      actions = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action])
      relation = relation.where(:traces => { :trace_key => actions.select(:trace_id) })
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


    [
      {:name => "50th Percentile", :data => latencies[:perc_50] },
      {:name => "75th Percentile", :data => latencies[:perc_75] },
      {:name => "90th Percentile", :data => latencies[:perc_90] },
      {:name => "95th Percentile", :data => latencies[:perc_95] },
      {:name => "99th Percentile", :data => latencies[:perc_99] }
    ]
  end
end
