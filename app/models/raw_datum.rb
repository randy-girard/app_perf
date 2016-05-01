class RawDatum < ActiveRecord::Base
  belongs_to :application

  has_many :transactions
  has_many :transaction_metrics
  has_many :transaction_metric_samples
  has_many :metrics

  serialize :body

  after_commit do |record|
    DataParserWorker.perform_async(record.id)
  end

  def memory_physical
    data_by_name("Memory/Physical", 3)
  end

  def gc_total_allocated_objects
    data_by_name("RubyVM/GC/total_allocated_object", 1)
  end

  def transaction_duration
    #start_at = Time.at(self.body[1])
    #end_at = Time.at(self.body[2])
    name =  "Controller/reports/index"
    items = self.body[2]
    items = items.select { |item| item[0]["name"] == name }

    items.map do |item|
      {
        :start_at => item[0]["timestamp"],
        :value => item[0]["duration"]
      }
    end
  end

  def body
    case method
    when "transaction_sample_data"
      body = super.dup
      body[1][0][4] = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(body[1][0][4])))
      body
    when "sql_trace_data"
      super.map {|data|
        data.map {|item|
          item[9] = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(item[9])))
          item[9]['backtrace'] = item[9]['backtrace'].split("\n")
          item
        }
      }
    else
      super
    end
  end

  private

  def data_by_name(name, index)
    start_at = Time.at(self.body[1])
    end_at = Time.at(self.body[2])

    items = self.body[3]
    items = items.select { |item| item[0]["name"] == name }

    items = {
      :start_at => start_at,
      :end_at => end_at,
      :value => items[0][1][index]
    }
  end
end
