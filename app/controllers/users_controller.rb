class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    user = UserInviter.new(user_params[:email], current_user).execute
    if user.valid?
      redirect_to dynamic_url(:users)
    else
      render "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      redirect_to dynamic_url(:users)
    else
      render "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to dynamic_url(:users)
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email
    )
  end
end
