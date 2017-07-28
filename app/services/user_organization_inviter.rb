class UserOrganizationInviter
  def initialize(email, organization, current_user = nil)
    self.email = email
    self.organization = organization
    self.current_user = current_user
  end

  def execute
    ActiveRecord::Base.transaction do
      create_user if user.nil?
      add_user_to_organization
      invite_user
    end
    user
  end

  private

  attr_accessor :email, :organization, :current_user

  def user
    @user ||= User.find_by_email(email)
  end

  def create_user
    @user = User.where(:email => email).first_or_initialize
    @user.password = SecureRandom.hex
    @user.save
    @user
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def add_user_to_organization
    user.organizations << organization
  end

  def invite_user
    user.invite!(current_user)
  end
end
