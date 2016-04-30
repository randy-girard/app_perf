class DashboardController < ApplicationController

  def show
    @applications = @current_user.applications
  end

end