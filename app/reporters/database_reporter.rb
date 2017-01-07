class DatabaseReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

  def report_data


    data = application
      .database_calls
      .joins(:database_type)
      .group("database_types.name")
      .group_by_period(*report_params("database_calls.timestamp"))
      .sum("database_calls.duration")

    hash = []
    layers = {}
    data.each_pair do |layer, event|
      layers[layer.first] ||= []
      layers[layer.first] << [layer.second.to_i * 1000, event]
    end

    layers.each_pair do |layer, data|
      hash.push({ :label => layer , :data => data, :id => "DATA1" }) rescue nil
    end

    {
      :data => hash
    }
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
          :plotLines => [],
          :type => 'datetime',
          :dateTimeLabelFormats => {
            :hour => '%I %p',
            :minute => '%I:%M %p'
          }
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
