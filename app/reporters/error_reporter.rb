class ErrorReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  def report_data
    data = application.analytic_event_data.where(:name => "Error")

    [{
      :name => "Errors",
      :data => data.group_by_period(*report_params).sum(:value)
    }]
  end

  private

  def report_colors
    ["#D3DE00"]
  end

  def report_options
    {
      :id => "error_chart",
      :height => "100%",
      :library => {
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