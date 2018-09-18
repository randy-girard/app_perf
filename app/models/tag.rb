class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :metric_data, through: :taggings

  def cpu_usage
    sys = system_cpu("system")
    user = system_cpu("user")
    idle = system_cpu("idle")

    if sys && user && idle
      (sys + user).to_f / ((sys + user).to_f + idle.to_f)
    else
      nil
    end
  end

  def system_cpu(type)
    cte = MetricDatum
      .select("metric_data.timestamp")
      .select("metric_data.count")
      .select("metric_data.sum")
      .select("jsonb_object_agg(tags.key, tags.value) AS tags")
      .joins(:metric, :tags)
      .where(:metrics => { :name => "system.cpu.stats" })
      .where("timestamp >= ?", 1.hour.ago)
      .where("tags.key IS NOT NULL")
      .where("tags.value IS NOT NULL")
      .group("metric_data.timestamp")
      .group("metric_data.count")
      .group("metric_data.sum")
      .group("taggings.uuid")

    values = MetricDatum
      .with(cte: cte)
      .from("cte")
      .select("cte.sum AS sum")
      .where("tags->>'host' = ?", name)
      .where("tags->>'metric' = ?", type)
      .order("cte.timestamp")
      .average("cte.sum")
   end
end
