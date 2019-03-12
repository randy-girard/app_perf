class WithFilterService
  def initialize(params, relation, application)
    @params = params
    @relation = relation
    @application = application
  end

  def call
    unless params.has_key?(:_layer)
      case params[:type]
      when "web"
        layer_ids = application.layers.where(name: "Rack").pluck(:id)
        @relation = relation.where("root_spans_traces.layer_id IN (?)", layer_ids)
      when "worker"
        layer_ids = application.layers.where(name: "Sidekiq").pluck(:id)
        @relation = relation.where("root_spans_traces.layer_id IN (?)", layer_ids)
      end
    end

    if params[:_domain]
      domains = relation.where("spans.payload->>'peer.address' = ?", params[:_domain])
      @relation = relation.where(:traces => { :trace_key => domains.select("spans.trace_key") })
    end
    if params[:_url]
      urls = relation.where("spans.payload->>'http.url' = ?", params[:_url])
      @relation = relation.where(:traces => { :trace_key => urls.select("spans.trace_key") })
    end
    if params[:_controller]
      controllers = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller])
      @relation = relation.where(:traces => { :trace_key => controllers.select("spans.trace_key") })
    end
    if params[:_action]
      actions = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action])
      @relation = relation.where(:traces => { :trace_key => actions.select("spans.trace_key") })
    end
    @relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    @relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    if params[:_sql]
      @relation = relation.joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")
      @relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql])
    end
    relation
  end

  private

  attr_accessor :params, :relation, :application
end
