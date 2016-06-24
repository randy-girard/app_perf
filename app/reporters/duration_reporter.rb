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
    data = application.transaction_data
    if params[:transaction_id]
      data = data.where(:transaction_endpoint_id => params[:transaction_id])
    end

    hash = []
    hash.push({ :name => "View", :data => data.group_by_period(*report_params).calculate_all("CASE COUNT(*) WHEN 0 THEN 0 ELSE SUM(view_duration) / COUNT(*) END") }) rescue nil
    hash.push({ :name => "App", :data => data.group_by_period(*report_params).calculate_all("CASE COUNT(*) WHEN 0 THEN 0 ELSE SUM(app_duration) / COUNT(*) END") }) rescue nil
    hash.push({ :name => "Database", :data => data.group_by_period(*report_params).calculate_all("CASE COUNT(*) WHEN 0 THEN 0 ELSE SUM(db_duration) / COUNT(*) END") }) rescue nil
    hash.push({ :name => "Middleware", :data => data.group_by_period(*report_params).calculate_all("CASE COUNT(*) WHEN 0 THEN 0 ELSE SUM(middleware_duration) / COUNT(*) END") }) rescue nil
    hash.push({ :name => "GC Execution", :data => data.group_by_period(*report_params).calculate_all("CASE COUNT(*) WHEN 0 THEN 0 ELSE SUM(gc_duration) / COUNT(*) END") }) rescue nil
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