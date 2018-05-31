require 'digest/sha1'

class Metric < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  has_many :metric_data, :dependent => :delete_all

  def clean_name
    Digest::SHA1.hexdigest(data_type.to_s.downcase)
  end

  def self.metricify(type, value)
    case type.to_s.downcase
    when "cpu"
      value
    when "memory"
      value / 1.gigabyte
    when "network"
      value / 1.gigabyte
    when "disk"
      value / 1.gigabyte
    when "load"
      value
    else
      value
    end
  end

  def unit
    case data_type.to_s.downcase
    when "cpu"
      "kb"
    when "memory"
      "gb"
    when "network"
      "gb"
    when "disk"
      "gb"
    when "load"
      ""
    else
      ""
    end
  end
end
