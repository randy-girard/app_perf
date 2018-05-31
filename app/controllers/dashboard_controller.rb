class DashboardController < ApplicationController
  def show
    @applications = Application.all
  end

end
