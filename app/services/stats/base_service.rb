class Stats::BaseService

  LIMITS = {
    "10" => 10,
    "20" => 20,
    "50" => 50
  }

  ORDERS = {
    "Freq" => "SUM(count) DESC",
    "Avg" => "SUM(sum) / SUM(count) DESC",
    "FreqAvg" => "SUM(count) * SUM(sum) / SUM(count) DESC"
  }

  def initialize(application, time_range, params)
    @application = application
    @time_range = time_range
    @params = params
  end

  private

  attr_accessor :application,
                :time_range,
                :params,
                :traces

  def traces
    @traces = WithFilterService.new(params, base_relation).call
  end

  def base_relation
    application
      .traces
      .joins(:spans)
      .where(:timestamp => time_range)
  end
end
