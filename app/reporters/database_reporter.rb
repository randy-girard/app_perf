class DatabaseReporter < Reporter

  def render
    view_context.area_chart(report_data, report_options)
  end

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
