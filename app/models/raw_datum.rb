class RawDatum < ActiveRecord::Base
  belongs_to :application
  belongs_to :host

  serialize :body
end
