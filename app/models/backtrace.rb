class Backtrace < ActiveRecord::Base
  belongs_to :backtraceable, polymorphic: true
end
