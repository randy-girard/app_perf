class DashboardController < ApplicationController
  skip_before_action :authorize_current_organization!
  
  def show
    @organizations = current_user.organizations
  end

end
