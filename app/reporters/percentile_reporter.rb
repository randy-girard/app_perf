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

    relation = relation.where("spans.payload->>'domain' = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("spans.payload->>'url' = ?", params[:_url]) if params[:_url]
    relation = relation.where("spans.payload->>'controller' = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("spans.payload->>'action' = ?", params[:_action]) if params[:_action]
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]

    data = relation
      .group_by_period(*report_params)

    @perc_50 = data.calculate_all("percentile_disc(0.50) within group (order by #{table}.duration)")
    @perc_75 = data.calculate_all("percentile_disc(0.75) within group (order by #{table}.duration)")
    @perc_90 = data.calculate_all("percentile_disc(0.90) within group (order by #{table}.duration)")
    @perc_95 = data.calculate_all("percentile_disc(0.95) within group (order by #{table}.duration)")
    @perc_99 = data.calculate_all("percentile_disc(0.99) within group (order by #{table}.duration)")

    hash = [
      {"name" => "50th Percentile", :data => @perc_50 },
      {"name" => "75th Percentile", :data => @perc_75 },
      {"name" => "90th Percentile", :data => @perc_90 },
      {"name" => "95th Percentile", :data => @perc_95 },
      {"name" => "99th Percentile", :data => @perc_99 }
    ]


    deployments = application
      .deployments
      .where("start_time BETWEEN :start AND :end OR end_time BETWEEN :start AND :end", :start => time_range.first, :end => time_range.last)

    {
      :data => hash,
      :annotations => deployments.map {|deployment|
        {
          :value => deployment.start_time.to_i * 1000,
          :color => '#FF0000',
          :width => 2
        }
      }
    }
  end
end
