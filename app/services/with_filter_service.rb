class WithFilterService
  def initialize(params, relation)
    @params = params
    @relation = relation
  end

  def call
    if params[:_domain]
      domains = relation.where("spans.payload->>'peer.address' = ?", params[:_domain])
      @relation = relation.where(:traces => { :trace_key => domains.select(:trace_id) })
    end
    if params[:_url]
      urls = relation.where("spans.payload->>'http.url' = ?", params[:_url])
      @relation = relation.where(:traces => { :trace_key => urls.select(:trace_id) })
    end
    if params[:_controller]
      controllers = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller])
      @relation = relation.where(:traces => { :trace_key => controllers.select(:trace_id) })
    end
    if params[:_action]
      actions = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action])
      @relation = relation.where(:traces => { :trace_key => actions.select(:trace_id) })
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

  attr_accessor :params, :relation
end
