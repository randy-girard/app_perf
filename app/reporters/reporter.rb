class Reporter

  def initialize(application, params, view_context)
    params[:period] ||= "minute"

    self.application = application
    self.params = params
    self.view_context = view_context
  end

  def render
  end

  def pre_render
  end

  def post_render
  end

  def report_data
    []
  end

  private

  def report_colors
    []
  end

  def report_params
    options = {}
    options[:permit] = %w[minute hour day]
    if time_range
      options[:range] = time_range
    else
      options[:last] = (params[:last] || 10)
    end

    [
      params[:period],
      :timestamp,
      options
    ]
  end

  def time_range
    start_time = params[:st] ? Time.at(params[:st].to_i).beginning_of_minute : nil
    end_time = params[:se] ? Time.at(params[:se].to_i).beginning_of_minute + 1.minute : nil

    if start_time && end_time
      start_time..end_time
    else
      nil
    end
  end

  attr_accessor :application, :params, :view_context
end