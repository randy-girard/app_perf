class DatabaseReporter < Reporter
  def report_data
    time_range, period = Reporter.time_range(params)

    data = application
      .database_calls
      .joins(:database_type, :span)
      .group("database_types.name")
      .group_by_period(*report_params("database_calls.timestamp"))

    data = data.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    data = data.sum("database_calls.duration")

    hash = []
    layers = {}
    labels = []
    data.each_pair do |layer, event|
      layers[layer.first] ||= []
      layers[layer.first] << [layer.second, event]
    end

    layers.each_pair do |layer, data|
      hash.push({ :name => layer , :data => data, :id => "DATA1" }) rescue nil
    end

    hash
  end
end
