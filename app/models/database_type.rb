class DatabaseType < ApplicationRecord
  belongs_to :application, optional: true

  has_many :database_calls
end
