class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }

  def index
  end

  def create
    message = JSON.parse request.raw_post
    message['from'] = message['from'].with_protocol 'sms'
    context = application.accept_message message
    if context
      render json: {messages: context.messages, actions: context.logger.actions_as_strings}
    else
      render json: false
    end
  end

  private

  def set_tab
    @application_tab = :messages
  end
end
