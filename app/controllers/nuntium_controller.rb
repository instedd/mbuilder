class NuntiumController < ApplicationController
  skip_filter :authenticate_user!
  skip_filter :check_guisso_cookie

  before_filter :authenticate
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Nuntium::Config['incoming_username'] && password == Nuntium::Config['incoming_password']
    end
  end

  def receive_at
    channel = Channel.find_by_pigeon_name params[:channel]
    if channel
      context = channel.application.accept_message params
      if context && context.messages.any?
        render json: context.messages.to_json
      else
        head :ok
      end
    else
      head :ok
    end
  end
end
