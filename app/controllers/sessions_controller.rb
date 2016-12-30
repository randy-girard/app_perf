class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:destroy]
  skip_before_filter :authenticate_user!, :only => [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    # If the user exists AND the password entered is correct.
    if user && user.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = user.id
      redirect_to root_url
    else
    # If user's login doesn't work, send them back to the login form.
      redirect_to new_user_session_url
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_user_session_url
  end

end
