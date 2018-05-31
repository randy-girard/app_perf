class Stats::BaseService

  LIMITS = {
    "10" => 10,
    "20" => 20,
    "50" => 50
  }

  ORDERS = {
    "Freq" => "COUNT(DISTINCT traces.id) DESC",
    "Avg" => "(SUM(traces.duration) / COUNT(DISTINCT traces.id)) DESC",
    "FreqAvg" => "(COUNT(DISTINCT traces.id) * SUM(traces.duration) / COUNT(DISTINCT traces.id)) DESC"
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
