class OverviewController < ApplicationController
  def show
    session[:application_id] = @current_application.id
  end
end
