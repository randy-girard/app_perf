class Stats::LatencyBandsService < Stats::BaseService
  def call
    if params[:_layer].present?
      @traces = traces
        .select("spans.id, spans.timestamp, spans.exclusive_duration AS duration")
        .where("spans.layer_id = ?", params[:_layer])
    end

    period, timestamp, options = report_params

    data = Trace
      .with(trace_cte: traces.distinct)
      .from("trace_cte")
      .group_by_period(period, timestamp, options)
      .order("histogram_bucket(histogram(duration, 0, (SELECT max(duration) FROM trace_cte), 10)) DESC")
      .calculate_all_hashes(
        count: "histogram_count(histogram(duration, 0, (SELECT max(duration) FROM trace_cte), 10))",
        range: "histogram_range(histogram(duration, 0, (SELECT max(duration) FROM trace_cte), 10))"
      )

    hash = []
    buckets = {}
    ranges = data.values.flatten.select {|d| d.is_a?(Hash) }.map {|d| d[:range] }.uniq

    ranges.each do |range|
      f = range.first.to_i
      e = range.last.to_i
      buckets["#{f}ms - #{e}ms"] ||= []

      data.each do |datum|
        item = datum.last
        if item == 0
          d = { count: 0 }
        else
          d = item.find {|d| d[:range] == range }
        end

        buckets["#{f}ms - #{e}ms"] << [datum.first, d[:count] || 0]
      end
    end

    gradient = Gradient.new(colors: ["#2c01ba", "#c1012b"], steps: 10)
    colors = gradient.hex.reverse

    buckets.each_with_index do |(bucket, data), index|
      hash.push({
        :name => bucket,
        :data => data,
        :color => colors[index],
        :id => "ID-#{bucket}"
      })
    end

    hash
  end
end
