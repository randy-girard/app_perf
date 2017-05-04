class User::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :accept_invitation,
      keys: [
        :name,
        :password,
        :password_confirmation
      ]
    )
  end
end
