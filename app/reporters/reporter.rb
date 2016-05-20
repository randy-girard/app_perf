class Reporter

  def initialize(application, params, view_context)
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
    (Time.now - 10.minutes)..Time.now
  end

  attr_accessor :application, :params, :view_context
end