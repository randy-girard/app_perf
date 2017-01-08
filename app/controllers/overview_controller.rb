class OverviewController < ApplicationController

  before_filter :set_traces, :only => [:urls, :layers, :database_calls, :traces, :controllers, :hosts]

  def show

  end

  def urls
    @urls = @current_application
      .transaction_sample_data
      .select("domain, url, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces)
      .where("domain IS NOT NULL AND url IS NOT NULL")
      .group("domain, url")
      .order("(COUNT(DISTINCT trace_id) * SUM(exclusive_duration) / COUNT(DISTINCT trace_id)) DESC")
      .limit("10")

    render :layout => false
  end

  def layers
    @layers = @current_application
      .layers
      .select("layers.id, layers.name, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .joins(:transaction_sample_data)
      .where(:transaction_sample_data => { :trace_id => @_traces })
      .order("(COUNT(DISTINCT trace_id) * SUM(exclusive_duration) / COUNT(DISTINCT trace_id)) DESC")
      .group("layers.id, layers.name")
    if params[:_layer].present?
      @layers = @layers.where("transaction_sample_data.layer_id = ?", params[:_layer])
    end

    render :layout => false
  end

  def database_calls
    @database_calls = @current_application
      .database_calls
      .select("database_calls.statement, MAX(database_calls.id) AS id, COUNT(*) AS freq, SUM(database_calls.duration) / COUNT(*) AS average")
      .joins(:database_sample)
      .where(:transaction_sample_data => { :trace_id => @_traces })
      .where("statement IS NOT NULL")
      .group("database_calls.statement")
      .order("SUM(database_calls.duration) / COUNT(*) DESC")
      .limit(10)

    render :layout => false
  end

  def traces
    @traces = @current_application
      .traces
      .where(:id => @_traces)
      .order("traces.timestamp DESC")
      .limit(10)

    render :layout => false
  end

  def controllers
    @controllers = @current_application
      .transaction_sample_data
      .where("controller IS NOT NULL AND action IS NOT NULL")
      .select("controller, action, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .where(:trace_id => @_traces)
      .group("controller, action")
      .order("(COUNT(DISTINCT trace_id) * SUM(exclusive_duration) / COUNT(DISTINCT trace_id)) DESC")
      .limit("10")

    render :layout => false
  end

  def hosts
    @hosts = @current_application
      .hosts
      .select("hosts.id, hosts.name, COUNT(DISTINCT trace_id) AS freq, SUM(exclusive_duration) / COUNT(DISTINCT trace_id) AS average")
      .joins(:transaction_sample_data)
      .where(:transaction_sample_data => { :trace_id => @_traces })
      .where("hosts.name IS NOT NULL")
      .group("hosts.id, hosts.name")
      .order("(COUNT(DISTINCT transaction_sample_data.trace_id) * SUM(transaction_sample_data.exclusive_duration) / COUNT(DISTINCT transaction_sample_data.trace_id)) DESC")
      .limit(10)

    render :layout => false
  end

  private

  def set_traces
    @_traces = with_filters(@current_application
      .traces
      .joins(:transaction_sample_data)
      .where(:timestamp => @time_range)
      .where(:transaction_sample_data => { :sample_type => "web" })
    )
  end

  def with_filters(relation)
    relation = relation.where("transaction_sample_data.sample_type = ?", "web")
    relation = relation.where("transaction_sample_data.domain = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("transaction_sample_data.url = ?", params[:_url]) if params[:_url]
    relation = relation.where("transaction_sample_data.controller = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("transaction_sample_data.action = ?", params[:_action]) if params[:_action]
    relation = relation.where("transaction_sample_data.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("transaction_sample_data.host_id = ?", params[:_host]) if params[:_host]
    if params[:_sql]
      relation = relation.joins("LEFT JOIN database_calls ON database_calls.uuid = transaction_sample_data.grouping_id AND transaction_sample_data.grouping_type = 'DatabaseCall'")
      relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql])
    end
    relation
  end
end
