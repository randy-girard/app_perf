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

  def parse(items)
    items.map do |item|
      raise item.inspect
      [
        item.first.to_i * 1000,
        item.last
      ]
    end
  end

  def report_colors
    []
  end

  def report_params
    options = {}
    options[:permit] = %w[minute hour day]
    if (time_range = Reporter.time_range(params))
      options[:range] = time_range
    else
      options[:last] = (params[:_last] || 60)
    end

    [
      params[:period],
      "transaction_sample_data.timestamp",
      options
    ]
  end

  def self.time_range(params)
    params.delete(:_past) if params[:_st] && params[:_se]
    params.delete(:_interval) if params[:_st] && params[:_se]

    if params[:_past] && params[:_interval]
      @start_time = (Time.now - params[:_interval].to_i.send(params[:_past])).beginning_of_minute
      @end_time = Time.now.end_of_minute
    else
      @start_time = (params[:_st] ? Time.at(params[:_st].to_i) : Time.now - 60.minutes).beginning_of_minute
      @end_time = (params[:_se] ? Time.at(params[:_se].to_i) : Time.now).end_of_minute
    end

    if @start_time && @end_time
      @start_time..@end_time
    else
      nil
    end
  end

  attr_accessor :application, :params, :view_context
end
