class DatabaseSampleReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  def report_data
    application
      .database_calls
      .includes(:database_samples => :transaction_endpoint)
      .where(:database_calls => { :id => params[:database_id] })
      .group("transaction_endpoints.name")
      .group_by_minute(:started_at, range: time_range)
      .sum("transaction_sample_data.exclusive_duration")
  end

  private

  def report_options
    {
      :id => "database_chart",
      :height => "100%",
      :library => {
        :legend => {
          :position => "bottom"
        },
        :animation => false,
        :xAxis => {
          :plotLines => []
        },
        :plotOptions => {
          :area => {
            :stacking => "normal"
          }
        }
      }
    }
  end
end