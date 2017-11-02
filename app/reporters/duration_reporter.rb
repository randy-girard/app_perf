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
    time_range, period = Reporter.time_range(params)

    relation = application
      .layers
      .joins("LEFT JOIN spans ON spans.layer_id = layers.id")
      .joins("LEFT JOIN database_calls ON database_calls.span_id = spans.uuid")
      .group("layers.name")

    relation = relation.where("spans.payload->>'peer.address' = ?", params[:_domain]) if params[:_domain]
    relation = relation.where("spans.payload->>'http.url' = ?", params[:_url]) if params[:_url]
    relation = relation.where("split_part(spans.operation_name, '#', 1) = ?", params[:_controller]) if params[:_controller]
    relation = relation.where("split_part(spans.operation_name, '#', 2) = ?", params[:_action]) if params[:_action]
    relation = relation.where("spans.layer_id = ?", params[:_layer]) if params[:_layer]
    relation = relation.where("spans.host_id = ?", params[:_host]) if params[:_host]
    relation = relation.where("database_calls.statement = (SELECT statement FROM database_calls WHERE id = ?)", params[:_sql]) if params[:_sql]

    data = relation
      .group_by_period(*report_params)
      .calculate_all("CASE COUNT(DISTINCT trace_id) WHEN 0 THEN 0 ELSE SUM(spans.exclusive_duration) / COUNT(DISTINCT trace_id) END")

    hash = []
    layers = {}
    data.each_pair do |layer, event|
      layers[layer.first] ||= []
      layers[layer.first] << [layer.second, event]
    end

    layers.each_pair do |layer, data|
      hash.push({
        :name => layer,
        :data => data,
        :color => "##{Digest::MD5.hexdigest(layer)[0..5]}",
        :id => "ID-#{layer}"
      }) rescue nil
    end

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
