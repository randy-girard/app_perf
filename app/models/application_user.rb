class ApplicationUser < ActiveRecord::Base
  belongs_to :application, :inverse_of => :application_users
  belongs_to :user, :inverse_of => :application_users
end
