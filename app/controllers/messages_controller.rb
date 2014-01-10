class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }

  def index
  end

  def create
    message = JSON.parse request.raw_post
    message['from'] = message['from'].with_protocol 'sms'
    message['timestamp'] = Time.now.utc.to_s
    context = application.accept_message message
    if context
      nuntium = Pigeon::Nuntium.from_config
      # TODO: refactor this to avoid multiple messaging. Nuntium can handle multiple recipients
      context.messages.each do |message|
        nuntium.send_ao message
      end
      render_json messages: context.messages, actions: context.logger.actions_as_strings
    else
      render_json false
    end
  end

  private

  def set_tab
    @application_tab = :messages
  end
end
