class DashboardController < ApplicationController

  def show
    @organizations = current_user.organizations
  end

end
