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

  before_filter :set_traces, :only => [:urls, :layers, :database_calls, :traces, :controllers, :hosts]

  def show
    session[:organization_id] = @current_organization.id
    session[:application_id] = @current_application.id

    @view_context = view_context
  end

  def urls
    @urls = @current_application
      .spans
      .select("domain, url, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces)
      .where("domain IS NOT NULL AND url IS NOT NULL")
      .group("domain, url")
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
      .where(:spans => { :trace_id => @_traces })
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
      .select("database_calls.statement, MAX(database_calls.id) AS id, COUNT(*) AS freq, SUM(database_calls.duration) / COUNT(*) AS average")
      .joins(:database_span)
      .where(:spans => { :trace_id => @_traces })
      .where("statement IS NOT NULL")
      .group("database_calls.statement")
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
      .where("controller IS NOT NULL AND action IS NOT NULL")
      .select("controller, action, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces)
      .group("controller, action")
      .order(ORDERS[params[:_order]] || ORDERS["FreqAvg"])
      .limit(LIMITS[params[:_limit]] || LIMITS["10"])
  end

  def hosts
    @hosts = @current_organization
      .hosts
      .select("hosts.id, hosts.name, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .joins(:spans)
      .where(:spans => { :trace_id => @_traces })
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
    relation = relation.where("spans.domain = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("spans.url = ?", params[:_url]) if params[:_url]
    relation = relation.where("spans.controller = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("spans.action = ?", params[:_action]) if params[:_action]
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    if params[:_sql]
      relation = relation.joins("LEFT JOIN database_calls ON database_calls.uuid = spans.grouping_id AND spans.grouping_type = 'DatabaseCall'")
      relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql])
    end
    relation
  end
end
