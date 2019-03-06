class DatabaseType < ApplicationRecord
  belongs_to :application

  has_many :database_calls
end
