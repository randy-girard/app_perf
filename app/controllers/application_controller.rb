class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :use_time_zone
  before_filter :authenticate_user!
  before_action :set_current_application
  before_action :set_application_scope
  before_action :set_current_page
  before_action :set_time_range

  layout :set_layout

  helper_method :enterprise?
  def enterprise?
    defined?(Enterprise)
  end

  helper_method :hosted?
  def hosted?
    defined?(Hosted)
  end

  helper_method :dynamic_url
  def dynamic_url(*args, **params)
    route = []
    route += args
    route << params

    route
  end

  helper_method :form_route
  def form_route(*args)
    route = []
    route += args
    route
  end

  def set_application_scope
    @application_scope = Application.all
  end

  def set_current_application
    @application_scope = Application
    if current_user
      if params[:application_id]
        @current_application ||= @application_scope.find_by_id(params[:application_id])
      elsif session[:application_id]
        @current_application ||= @application_scope.find_by_id(session[:application_id])
      end
      @current_scope = @current_application
    end
  end

  def set_current_page
    @current_page = {
      "#{self.class}" => "active",
      "#{self.class}##{action_name}" => "active"
    }
  end

  def set_layout
    if current_user
      "application"
    else
      "public"
    end
  end

  def use_time_zone(&block)
    Time.use_zone('Eastern Time (US & Canada)', &block)
  end

  def set_time_range
    @time_range, @period = Reporter.time_range(params)
  end
end
