class MemoryReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  def report_data
    data = application.metrics.where(:name => "Memory")

    [{
      :name => "Memory Usage",
      :data => data.group_by_period(*report_params).average(:value)
    }]
  end

  private

  def report_colors
    ["#A5FFFF"]
  end

  def report_options
    {
      :id => "memory_chart",
      :height => "100%",
      :library => {
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
