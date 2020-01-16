class Layer < ApplicationRecord
  belongs_to :application, optional: true

  has_many :spans

  validates :name, :uniqueness => { :scope => :application_id }

  def database?
    ["sequel", "activerecord"].include?(name)
  end

  def http?
    ["net-http"].include?(name)
  end
end
