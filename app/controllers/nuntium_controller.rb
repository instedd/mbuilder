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
    application = nil
    begin
      channel = Channel.find_by_pigeon_name params[:channel]
      application = channel.application
      context = application.accept_message params
      if context && context.messages.any?
        render json: context.messages.to_json
      else
        head :ok
      end
    rescue Exception => e
      ExecutionLogger.new(application: application).tap do |logger|
        logger.message = params
        logger.error(e.message)
        logger.save!
      end
      head :ok
    end
  end
end
