class NuntiumController < ApplicationController
  skip_filter :authenticate_worker!

  before_filter :authenticate
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Nuntium::Config['incoming_username'] && password == Nuntium::Config['incoming_password']
    end
  end

  def receive_at
    channel = Channel.find_by_pigeon_name params[:channel]
    messages = channel.application.accept_message params
    if messages.empty?
      head :ok
    else
      render json: messages.to_json
    end
  end
end
