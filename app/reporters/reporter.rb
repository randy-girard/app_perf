class Reporter
  PAST_OPTIONS = [
    { :label => "10m", :past => 1 * 10, :period => "minute" },
    { :label => "30m", :past => 1 * 30, :period => "minute" },
    { :label => "1h", :past => 1 * 60, :period => "minute" },
    { :label => "4h", :past => 4 * 60, :period => "minute" },
    { :label => "8h", :past => 8 * 60, :period => "hour" },
    { :label => "1d", :past => 1 * 60 * 24, :period => "hour" },
    { :label => "3d", :past => 3 * 60 * 24, :period => "hour" },
    { :label => "7d", :past => 7 * 60 * 24, :period => "hour" }
  ]

  def initialize(application, params)
    params[:period] ||= "minute"

    self.application = application
    self.params = params
  end

  def report_data
    []
  end

  private

  def report_params(timestamp = "spans.timestamp")
    options = { }
    options[:permit] = %w[minute hour day]
    time_range, period = Reporter.time_range(params)
    if time_range
      options[:range] = time_range
    else
      options[:last] = (params[:_last] || 60)
    end

    [
      period,
      timestamp,
      options
    ]
  end

  def self.time_range(params)
    params.delete(:_past) if params[:_st] && params[:_se]

    if params[:_past]
      time_ago, @period = Reporter.parse_past_intervals(params)
      @start_time = (Time.now - time_ago).beginning_of_minute
      @end_time = Time.now.end_of_minute
    else
      @start_time = (params[:_st] ? Time.at(params[:_st].to_i) : Time.now - 60.minutes).beginning_of_minute
      @end_time = (params[:_se] ? Time.at(params[:_se].to_i) : Time.now).end_of_minute
      @period = "minute"
    end

    if @start_time && @end_time
      return @start_time..@end_time, @period
    else
      return nil, @period
    end
  end

  def self.parse_past_intervals(params)
    past = params[:_past]
    past_option = PAST_OPTIONS.find {|option| option[:past].to_s == past.to_s }
    if past_option
      time_ago, period = past.to_i.minutes, past_option[:period]
    else
      time_ago, period = 60.minutes, "minute"
    end

    return time_ago, period
  end

  attr_accessor :application, :params
end
