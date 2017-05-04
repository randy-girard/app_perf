class Metric < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  def clean_name
    name.to_s.downcase.gsub(/[^a-z0-9].*/, "-")
  end
end
