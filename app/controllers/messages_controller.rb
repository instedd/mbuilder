class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }

  def index
  end

  def create
    message = JSON.parse request.raw_post
    message['from'] = message['from'].with_protocol 'sms'
    messages = application.accept_message message
    render json: messages
  end

  private

  def set_tab
    @application_tab = :messages
  end
end
