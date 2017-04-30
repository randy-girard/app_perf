class UsersController < ApplicationController
  before_action :set_application

  def index
    @users = @application.users
  end

  def new
    @user = @application.users.new
  end

  def create
    user = UserApplicationInviter.new(user_params[:email], @application, current_user).execute
    if user.valid?
      redirect_to application_users_path(@application)
    else
      render "new"
    end
  end

  def edit
    @user = @application.users.find(params[:id])
  end

  def update
    @user = @application.users.find(params[:id])

    if @user.update_attributes(user_params)
      redirect_to application_users_path(@application)
    else
      render "edit"
    end
  end

  def destroy
    @user = @application.application_users.where(:user_id => params[:id]).first
    @user.destroy

    redirect_to application_users_path(@application)
  end

  private

  def set_application
    @application = current_user.applications.find(params[:application_id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email
    )
  end
end
