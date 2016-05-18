class DurationReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  private

  def report_data
    data = application.transaction_data
    if params[:transaction_id]
      data = data.where(:transaction_endpoint_id => params[:transaction_id])
    end

    hash = []
    hash.push({ :name => "Ruby", :data => data.group_by_minute(:timestamp, range: time_range).calculate_all("CASE SUM(call_count) WHEN 0 THEN 0 ELSE SUM(duration) / SUM(call_count) END") }) rescue nil
    hash.push({ :name => "Database", :data => data.group_by_minute(:timestamp, range: time_range).calculate_all("CASE SUM(db_call_count) WHEN 0 THEN 0 ELSE SUM(db_duration) / SUM(db_call_count) END") }) rescue nil
    hash.push({ :name => "GC Execution", :data => data.group_by_minute(:timestamp, range: time_range).calculate_all("CASE SUM(gc_call_count) WHEN 0 THEN 0 ELSE SUM(gc_duration) / SUM(gc_call_count) END") }) rescue nil
    hash
  end

  def report_colors
    ["#A5FFFF", "#EECC45", "#4E4318"]
  end

  def report_options
    {
      :id => "duration_chart",
      :height => "100%",
      :library => {
        :area => {
          :stacking => "normal"
        },
        :colors => report_colors,
        :legend => {
          :position => "bottom"
        },
        :animation => false,
        :xAxis => {
          :plotLines => []
        }
      }
    }
  end
end