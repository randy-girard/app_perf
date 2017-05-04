class UserApplicationInviter
  def initialize(email, application, current_user = nil)
    self.email = email
    self.application = application
    self.current_user = current_user
  end

  def execute
    ActiveRecord::Base.transaction do
      create_user if user.nil?
      add_user_to_application
      invite_user
    end
    user
  end

  private

  attr_accessor :email, :application, :current_user

  def user
    @user ||= User.find_by_email(email)
  end

  def create_user
    @user = User.where(:email => email).first_or_initialize
    @user.password = SecureRandom.hex
    @user.save
    @user
  end

  def application
    @application ||= Application.find(application_id)
  end

  def add_user_to_application
    user.applications << application
  end

  def invite_user
    user.invite!(current_user)
  end
end
