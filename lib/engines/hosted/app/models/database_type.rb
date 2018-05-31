class DatabaseType < ActiveRecord::Base
  belongs_to :organization
  belongs_to :application

  has_many :database_calls
end
