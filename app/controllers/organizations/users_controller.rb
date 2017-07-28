class Organizations::UsersController < ApplicationController
  before_action :set_organization

  def index
    @users = @organization.users
  end

  def new
    @user = @organization.users.new
  end

  def create
    user = UserOrganizationInviter.new(user_params[:email], @organization, current_user).execute
    if user.valid?
      redirect_to organization_users_path(@organization)
    else
      render "new"
    end
  end

  def edit
    @user = @organization.users.find(params[:id])
  end

  def update
    @user = @organization.users.find(params[:id])

    if @user.update_attributes(user_params)
      redirect_to organization_users_path(@organization)
    else
      render "edit"
    end
  end

  def destroy
    @user = @organization.organization_users.where(:user_id => params[:id]).first
    @user.destroy

    redirect_to organization_users_path(@organization)
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email
    )
  end
end
