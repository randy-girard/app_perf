class Reporter

  def initialize(application, params, view_context)
    params[:period] ||= "minute"

    self.application = application
    self.params = params
    self.view_context = view_context
  end

  def render
  end

  def report_data
    []
  end

  private

  def report_colors
    []
  end

  def time_range
    start_time = params[:st] ? Time.at(params[:st].to_i) : Time.now - 10.minutes
    end_time = params[:se] ? Time.at(params[:se].to_i) : Time.now
    start_time..end_time
  end

  attr_accessor :application, :params, :view_context
end