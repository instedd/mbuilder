class MessagesController < MbuilderApplicationController
  add_breadcrumb 'Messages'
  set_application_tab :messages

  def index
  end

  def create
    message = JSON.parse request.raw_post
    message['from'] = message['from'].with_protocol 'sms'
    message['timestamp'] = Time.now.utc.to_s
    context = application.accept_message message
    if context
      if context.messages.present?
        nuntium = Pigeon::Nuntium.from_config
        nuntium.send_ao context.messages
      end
      render_json messages: context.messages, actions: context.logger.actions_as_strings
    else
      render_json false
    end
  end
end
