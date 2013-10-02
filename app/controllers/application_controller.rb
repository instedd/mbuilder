class ApplicationController < ActionController::Base
  protect_from_forgery

  if Guisso.enabled?
    before_filter :sign_out_if_current_user_different_than_guisso
    def sign_out_if_current_user_different_than_guisso
      if current_user && current_user.email != cookies[:guisso]
        sign_out current_user
      end
    end

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
