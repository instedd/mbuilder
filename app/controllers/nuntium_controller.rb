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
    begin
      channel = Channel.find_by_pigeon_name params[:channel]
      context = channel.application.accept_message params
      if context.messages.any?
        render_json context.messages
      else
        head :ok
      end
    rescue Exception => e
      ExecutionLogger.new.error(e.message).save
      head :ok
    end
  end
end
