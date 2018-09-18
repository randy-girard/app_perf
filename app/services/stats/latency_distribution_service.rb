require 'hdr_histogram'

class Stats::LatencyDistributionService < Stats::BaseService
  def call
    time_range, period = Reporter.time_range(params)

    data = MetricDatum
      .joins(:metric, :tags)
      .where(metrics: { application_id: application })
      .where(timestamp: time_range)
      .calculate_all(
        "hdr_c_distribution(hdr_group(hdr_histogram))"
      )

    return data.map {|distribution|
      {
        name: "p#{distribution[1]}",
        data: { "#{distribution[0]} - #{distribution[1]}" => distribution[2] }
      }
    }


    a = MetricDatum
      .joins(", unnest_3d(histogram) AS s")
      .where(:timestamp => time_range)
      .where("histogram != '{}'")
      .group("s.start")
      .group("s.finish")
      .pluck_to_hash(
        "s.start AS start",
        "s.finish AS finish",
        "AVG(s.count) AS count"
      ).map {|object|
        {
          name: "p#{object[:finish]}",
          data: { "#{object[:start]} - #{object[:finish]}" => object[:count] }
        }
      }
  end
end
