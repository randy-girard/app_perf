class OverviewController < ApplicationController
  def show
    session[:organization_id] = @current_organization.id
    session[:application_id] = @current_application.id
  end
end
