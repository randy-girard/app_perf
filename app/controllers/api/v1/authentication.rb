module API
  module V1
    module Authentication
      extend ActiveSupport::Concern

      included do
        def warden
          env['warden']
        end

        def authenticated?
          return true if warden.authenticated?
          @params[:access_token] && @user = User.find_by(authentication_token: @params[:access_token])
        end

        def current_user
          warden.user || @user
        end

        def require_login!(r)
          unless authenticated?
            error 401, "Not Authorized"
          end
        end
      end
    end
  end
end
