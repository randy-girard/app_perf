class DataParserWorker < ActiveJob::Base
  queue_as :app_perf

  def perform(id)
    self.id = id
    execute
  end

  def self.delete_all
    Metric.delete_all
    TransactionMetricSample.delete_all
    TransactionMetric.delete_all
    Transaction.delete_all
  end

  def self.process_all
    RawDatum.find_each do |raw_data|
      DataParserWorker.perform_later(raw_data.id)
    end
  end

  def self.reset!
    delete_all
    process_all
  end

  def execute
    case raw_datum.method
    when "metric_data"
      parse_metric_data
    when "analytics_event_data"
      parse_analytics_event_data
    when "transaction_sample_data"
      parse_transaction_sample_data
    end
  end

  private

  attr_accessor :id

  def raw_datum
    @raw_datum ||= RawDatum.find(id)
  end

  def parse_metric_data
    start_at = raw_datum.body.dup[1]
    end_at = raw_datum.body.dup[2]
    delta = (start_at + end_at).to_f / 2.to_f
    data = raw_datum.body.dup[3]

    data.map { |item|
      hash = {}
      name = item[0]["name"]
      scope = item[0]["scope"]

      hash = {
        "application_id" => raw_datum.application_id,
        "raw_datum_id" => raw_datum.id,
        "name" => name,
        "scope" => scope,
        "timestamp" => Time.at(delta).utc,
        "value" => item[1][1],
        "raw_data" => item[1]
      }

      raw_datum.application.metrics.create(hash)
    }
  end

  def parse_analytics_event_data
    data = raw_datum.body.dup[2]
    data.map { |item|
      transaction_data = item[0]
      noop_data = item[1]
      http_data = item[2]

      hash = {
        "application_id" => raw_datum.application_id,
        "raw_datum_id" => raw_datum.id,
        "name" => transaction_data["name"],
        "timestamp" => Time.at(transaction_data["timestamp"]).utc,
        "duration" => transaction_data["duration"],
        "database_duration" => transaction_data["databaseDuration"],
        "database_count" => transaction_data["databaseCallCount"],
        "gc_duration" => transaction_data["gcCumulative"],
        "error" => transaction_data["error"],
        "method" => http_data["request.method"],
        "code" => http_data["httpResponseCode"]
      }

      transaction = raw_datum.application.transactions.where(:name => hash["name"]).first_or_create do |t|
        t.raw_datum = raw_datum
      end
      transaction.transaction_metrics.where("name" => hash["name"], "timestamp" => Time.at(transaction_data["timestamp"]).utc).first_or_initialize.update_attributes!(hash)
    }
  end

  def parse_transaction_sample_data
    data = raw_datum.body.dup[1]
    data.map { |item|
      transaction_name = item[2]
      transaction_data = item

      transaction = raw_datum.application.transactions.where(:name => transaction_name).first_or_create
      if transaction
        transaction_metric = transaction.transaction_metrics.where(
          :application_id => raw_datum.application_id,
          :name => transaction_name,
          :timestamp => Time.at(transaction_data[0]).utc
        ).first_or_create do |transaction_metric|
          transaction_metric.raw_datum = raw_datum
        end
        if transaction_metric
          hash = {
            "application_id" => raw_datum.application_id,
            "raw_datum_id" => raw_datum.id,
            "transaction_id" => transaction.id,
            "transaction_metric_id" => transaction_metric.id,
            "backtrace" => transaction_data
          }
          transaction_metric.transaction_metric_samples.create(hash)
        end
      end
    }
  end
end
