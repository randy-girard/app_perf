class MetricsWorker < ActiveJob::Base
  queue_as :app_perf

  attr_accessor :license_key,
                :name,
                :host,
                :hostname,
                :application

  def perform(license_key, hostname, name, data)
    _data = decompress_data(data)

    data = _data.fetch("data") { [] }
    tags = _data.fetch("tags") { {} }

    set_application(license_key, name)

    process_metrics(data, tags)
  end

  private

  def decompress_data(body)
    compressed_body = Base64.decode64(body)
    data = Zlib::Inflate.inflate(compressed_body)
    MessagePack.unpack(data)
  end

  def set_application(license_key, name)
    self.application = Application.where(:license_key => license_key).first_or_initialize
    self.application.name = name
    self.application.save
  end

  def process_metrics(data, tags)
    metrics = {}
    metric_data = []
    taggings = []

    data.each do |datum|
      timestamp, name, _tags, count, sum, histogram = *datum

      metrics[name] ||= Metric.where(name: name, application_id: application.try(:id)).first_or_create

      metric_datum = MetricDatum.new
      metric_datum.metric = metrics[name]
      metric_datum.timestamp = Time.at(timestamp)
      metric_datum.count = count
      metric_datum.sum = sum
      metric_datum.histogram = histogram

      if _tags.present?
        _tags.each do |tag|
          tag_id = tags[tag.to_i]
          if tag_id
            tagging = Tagging.new
            tagging.tag_id = tag_id
            tagging.uuid = metric_datum.uuid
            taggings << tagging
          end
        end
      end

      metric_data << metric_datum
    end
    MetricDatum.import(metric_data)
    Tagging.import(taggings)
  end
end
