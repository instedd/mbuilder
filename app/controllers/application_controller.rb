class ApplicationController < ActionController::Base
  protect_from_forgery

  if Rails.configuration.login_with_guisso
    def authenticate_user_with_guisso!
      if current_user
        guisso_email = cookies[:guisso]
        if guisso_email == current_user.email
          authenticate_user_without_guisso!
        else
          sign_out current_user
          redirect_to_guisso
        end
      else
        redirect_to_guisso
      end
    end
    alias_method_chain :authenticate_user!, :guisso

    def redirect_to_guisso
      redirect_to omniauth_authorize_path("user", "instedd")
    end
  end
end
