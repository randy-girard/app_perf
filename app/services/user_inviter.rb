class UserInviter
  def initialize(email, current_user = nil)
    self.email = email
    self.current_user = current_user
  end

  def execute
    ActiveRecord::Base.transaction do
      create_user if user.nil?
      invite_user
    end
    user
  end

  private

  attr_accessor :email, :current_user

  def user
    @user ||= User.find_by_email(email)
  end

  def create_user
    @user = User.where(:email => email).first_or_initialize
    @user.password = SecureRandom.hex
    @user.save
    @user
  end

  def invite_user
    user.invite!(current_user)
  end
end
