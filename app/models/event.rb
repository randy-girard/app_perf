class Event < ApplicationRecord
  belongs_to :application, optional: true
end
