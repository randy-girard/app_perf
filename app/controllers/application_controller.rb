class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :use_time_zone
  before_filter :authenticate_user!

  before_action :set_application

  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to new_user_session_url  unless current_user
  end

  def set_application
    if @current_user && params[:application_id]
      @application ||= @current_user.applications.find(params[:application_id])
    end
  end

  def use_time_zone(&block)
    Time.use_zone('Eastern Time (US & Canada)', &block)
  end
end
