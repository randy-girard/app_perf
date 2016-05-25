class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :use_time_zone
  before_filter :authenticate_user!

  before_action :set_current_application
  before_action :set_time_range

  layout :set_layout

  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to new_user_session_url unless current_user
  end

  def set_current_application
    if @current_user
      @applications = @current_user.applications
      if params[:application_id]
        @current_application ||= @applications.find {|a| a.id.eql?(params[:application_id].to_i) }
      end
    end
  end

  def set_layout
    if @current_application
      "current_application"
    else
      "application"
    end
  end

  def use_time_zone(&block)
    Time.use_zone('Eastern Time (US & Canada)', &block)
  end

  def set_time_range
    @start_time = params[:st] ? Time.at(params[:st].to_i) : Time.now - 10.minutes
    @end_time = params[:se] ? Time.at(params[:se].to_i) : Time.now
    @time_range = @start_time..@end_time
  end
end
