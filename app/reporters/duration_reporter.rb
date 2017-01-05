class DurationReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  def post_render

    js = <<-EOF
      $("#duration_chart").on('selection', function(event, min, max) {
        event.preventDefault();
        window.location = "/applications/1/transactions?custom=1&st=" + min + "&se=" + max
      });
    EOF
    view_context.javascript_tag { view_context.raw(js) }
  end

  def report_data
    relation = application
      .layers
      .joins("LEFT JOIN transaction_sample_data ON transaction_sample_data.layer_id = layers.id")
      .joins("LEFT JOIN database_calls ON database_calls.uuid = transaction_sample_data.grouping_id AND transaction_sample_data.grouping_type = 'DatabaseCall'")
      .where("transaction_sample_data.sample_type = ?", "web")
      .group("layers.name")

    relation = relation.where("transaction_sample_data.domain = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("transaction_sample_data.url = ?", params[:_url]) if params[:_url]
    relation = relation.where("transaction_sample_data.controller = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("transaction_sample_data.action = ?", params[:_action]) if params[:_action]
    relation = relation.where("transaction_sample_data.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("transaction_sample_data.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]

    data = relation
      .group_by_period(*report_params)
      .calculate_all("CASE COUNT(DISTINCT trace_id) WHEN 0 THEN 0 ELSE SUM(transaction_sample_data.exclusive_duration) / COUNT(DISTINCT trace_id) END")

    hash = []
    layers = {}
    data.each_pair do |layer, event|
      layers[layer.first] ||= []
      layers[layer.first] << [layer.second.to_i * 1000, event]
    end

    layers.each_pair do |layer, data|
      hash.push({ :label => layer , :data => data, :id => "DATA1" }) rescue nil
    end

    hash
  end

  private

  def report_colors
    ["#b51fa4", "#A5FFFF", "#5374b0", "#EECC45", "#4E4318"]
  end

  def report_options
    {
      :id => "duration_chart",
      :height => "100%",
      :library => {
        :chart => {
          :zoomType => "x"
        },
        :plotOptions => {
          :area => {
            :stacking => "normal"
          }
        },
        :colors => report_colors,
        :legend => {
          :position => "bottom"
        },
        :animation => false,
        :xAxis => {
          :plotLines => [],
          :type => 'datetime',
          :dateTimeLabelFormats => {
            :hour => '%I %p',
            :minute => '%I:%M %p'
          }
        }
      }
    }
  end
end
