class OverviewController < ApplicationController

  LIMITS = {
    "10" => 10,
    "20" => 20,
    "50" => 50
  }

  ORDERS = {
    "Freq" => "COUNT(DISTINCT trace_id) DESC",
    "Avg" => "(SUM(exclusive_duration) / COUNT(DISTINCT trace_id)) DESC",
    "FreqAvg" => "(COUNT(DISTINCT trace_id) * SUM(exclusive_duration) / COUNT(DISTINCT trace_id)) DESC"
  }

  before_filter :set_traces, :only => [:urls, :layers, :database_calls, :traces, :controllers, :hosts, :percentiles, :distributions]

  def show
    session[:organization_id] = @current_organization.id
    session[:application_id] = @current_application.id

    @view_context = view_context
  end

  def distributions
    if params[:_layer].present?
      @_traces = @_traces
        .select("spans.id, spans.exclusive_duration AS duration")
        .where("spans.layer_id = ?", params[:_layer])
    end

    @data = Trace
      .with(:trace_cte => @_traces)
      .from("trace_cte")
      .joins("RIGHT JOIN generate_series(1, 100) g(n) ON width_bucket(trace_cte.duration, 0, (select max(duration) + 1 from trace_cte), 100) = g.n")
      .select("g.n AS bucket, count(distinct trace_cte.id) AS count, min(trace_cte.duration) AS min_duration, max(trace_cte.duration) AS max_duration")
      .group("g.n")
      .order("g.n")

    render :json => { :data => @data.map {|d| ["#{d.bucket}: in #{d.min_duration.to_f.round(2)} to #{d.max_duration.to_f.round(2)}ms", d.count] } }
  end

  def urls
    @urls = @current_application
      .spans
      .select("spans.payload->>'peer.address' AS domain, spans.payload->>'http.url' AS url, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces.select(:trace_key))
      .where("spans.payload->>'peer.address' IS NOT NULL AND spans.payload->>'http.url' IS NOT NULL")
      .group("spans.payload->>'peer.address', spans.payload->>'http.url'")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  def layers
    orders = {
      "Freq" => "COUNT(trace_id) DESC",
      "Avg" => "(SUM(exclusive_duration) / COUNT(trace_id)) DESC",
      "FreqAvg" => "(COUNT(trace_id) * SUM(exclusive_duration) / COUNT(trace_id)) DESC"
    }

    @layers = @current_application
      .layers
      .select("layers.id, layers.name, COUNT(trace_id) AS freq, SUM(exclusive_duration) / COUNT(trace_id) AS average")
      .joins(:spans)
      .where(:spans => { :trace_id => @_traces.select(:trace_key) })
      .order(orders[params[:_order]] || orders["FreqAvg"])
      .group("layers.id, layers.name")
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
    if params[:_layer].present?
      @layers = @layers.where("spans.layer_id = ?", params[:_layer])
    end
  end

  def database_calls
    orders = {
      "Freq" => "COUNT(*) DESC",
      "Avg" => "(SUM(exclusive_duration) / COUNT(*)) DESC",
      "FreqAvg" => "(COUNT(DISTINCT trace_id) * SUM(exclusive_duration) / COUNT(*)) DESC"
    }

    @database_calls = @current_application
      .database_calls
      .select("layers.id AS layer_id, layers.name AS layer_name, database_calls.statement, MAX(database_calls.id) AS id, COUNT(*) AS freq, SUM(database_calls.duration) / COUNT(*) AS average")
      .joins(:span => :layer)
      .where(:spans => { :trace_id => @_traces.select(:trace_key) })
      .where("statement IS NOT NULL")
      .group("layers.id, layers.name, database_calls.statement")
      .order(orders[params[:_order]] || orders["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  def traces
    @traces = @current_application
      .traces
      .where(:id => @_traces)
      .order("traces.duration DESC")
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  def controllers
    @controllers = @current_application
      .spans
      .where("length(split_part(spans.operation_name, '#', 1)) > 0")
      .where("length(split_part(spans.operation_name, '#', 2)) > 0")
      .select("split_part(spans.operation_name, '#', 1) AS controller, split_part(spans.operation_name, '#', 2) as action, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces.select(:trace_key))
      .group("split_part(spans.operation_name, '#', 1), split_part(spans.operation_name, '#', 2)")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  def hosts
    @hosts = @current_organization
      .hosts
      .select("hosts.id, hosts.name, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .joins(:spans)
      .where(:spans => { :trace_id => @_traces.select(:trace_key) })
      .where("hosts.name IS NOT NULL")
      .group("hosts.id, hosts.name")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  private

  def set_traces
    @_traces = with_filters(@current_application
      .traces
      .joins(:spans)
      .where(:timestamp => @time_range)
    )
  end

  def with_filters(relation)
    relation = relation.where("spans.payload->>'peer.address' = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("spans.payload->>'http.url' = ?", params[:_url]) if params[:_url]
    relation = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action]) if params[:_action]
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    if params[:_sql]
      relation = relation.joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")
      relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql])
    end
    relation
  end
end
