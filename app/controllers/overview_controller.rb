class OverviewController < ApplicationController

  def show
    base_relation = @current_application
      .traces
      .joins(:root_sample, :transaction_sample_data => :host)
      .joins("LEFT JOIN database_calls ON database_calls.uuid = transaction_sample_data.grouping_id AND transaction_sample_data.grouping_type = 'DatabaseCall'")
      .where(:transaction_sample_data => { :timestamp => @time_range })
      .where(:transaction_sample_data => { :sample_type => "web" })

    @hosts = with_filters(
      base_relation
        .select("hosts.id, hosts.name, COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS freq, SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS average")
        .where("hosts.name IS NOT NULL")
        .order("(COUNT(DISTINCT transaction_sample_data_traces.trace_id) * SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id)) DESC")
        .group("hosts.id, hosts.name"))

    @layers = with_filters(@current_application
      .layers
      .select("layers.id, layers.name, CASE WHEN layers.name = 'sequel' then COUNT(*) else COUNT(DISTINCT trace_id) end AS freq, SUM(exclusive_duration) / CASE WHEN layers.name = 'sequel' then COUNT(*) else COUNT(DISTINCT trace_id) end AS average")
      .joins(:transaction_sample_data)
      .joins("LEFT JOIN database_calls ON database_calls.uuid = transaction_sample_data.grouping_id AND transaction_sample_data.grouping_type = 'DatabaseCall'")
      .where(:transaction_sample_data => { :timestamp => @time_range })
      .order("(CASE WHEN layers.name = 'sequel' then COUNT(*) else COUNT(DISTINCT trace_id) end * SUM(exclusive_duration) / CASE WHEN layers.name = 'sequel' then COUNT(*) else COUNT(DISTINCT trace_id) end) DESC")
      .group("layers.id, layers.name"))

     @database_calls = with_filters(@current_application
      .database_calls
      .select("database_calls.statement, MAX(database_calls.id) AS id, COUNT(*) AS freq, SUM(database_calls.duration) / COUNT(*) AS average")
      .where(:database_calls => { :timestamp => @time_range })
      .where("statement IS NOT NULL")
      .joins(:database_sample)
      .group("database_calls.statement")
      .order("SUM(database_calls.duration) / COUNT(*) DESC")
      .limit(10))

    traces = with_filters(@current_application
      .traces
      .eager_load(:root_sample, :transaction_sample_data => [:database_call])
      .where(:traces => { :timestamp => @time_range })
      .where(:transaction_sample_data => { :sample_type => "web" })
      .where("transaction_sample_data.id IS NOT NULL")
      .where("transaction_sample_data.url IS NOT NULL")
      .order("traces.timestamp DESC")
      .limit(10))
    @traces = @current_application
      .traces
      .where(:id => traces.pluck("id"))
      .order("traces.timestamp DESC")

    @controllers = with_filters(base_relation
      .where("transaction_sample_data_traces.controller IS NOT NULL AND transaction_sample_data_traces.action IS NOT NULL")
      .select("transaction_sample_data_traces.controller, transaction_sample_data_traces.action, COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS freq, SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS average")
      .group("transaction_sample_data_traces.controller, transaction_sample_data_traces.action")
      .order("(COUNT(DISTINCT transaction_sample_data_traces.trace_id) * SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id)) DESC")
      .limit("10"))

    @urls = with_filters(base_relation
      .where("transaction_sample_data_traces.domain IS NOT NULL AND transaction_sample_data_traces.url IS NOT NULL")
      .select("transaction_sample_data_traces.domain, transaction_sample_data_traces.url, COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS freq, SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id) AS average")
      .group("transaction_sample_data_traces.domain, transaction_sample_data_traces.url")
      .order("(COUNT(DISTINCT transaction_sample_data_traces.trace_id) * SUM(transaction_sample_data_traces.exclusive_duration) / COUNT(DISTINCT transaction_sample_data_traces.trace_id)) DESC")
      .limit("10"))
  end

  private

  def with_filters(relation)
    relation = relation.where("transaction_sample_data.sample_type = ?", "web")
    relation = relation.where("transaction_sample_data.domain = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("transaction_sample_data.url = ?", params[:_url]) if params[:_url]
    relation = relation.where("transaction_sample_data.controller = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("transaction_sample_data.action = ?", params[:_action]) if params[:_action]
    relation = relation.where("transaction_sample_data.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("transaction_sample_data.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]
    relation
  end
end
