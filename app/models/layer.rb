class Layer < ActiveRecord::Base
  belongs_to :application

  has_many :transaction_sample_data

  validates :name, :uniqueness => { :scope => :application_id }

  def database?
    ["sequel", "activerecord"].include?(name)
  end

  def http?
    ["net-http"].include?(name)
  end
end
