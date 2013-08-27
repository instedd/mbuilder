class Actions::SendMessageAction < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def execute(context)
    recipient = @recipient.solve(context)
    message = @message.map { |binding| binding.solve(context) }.join " "
    context.send_message(recipient, message)
  end

  def self.from_hash(hash)
    new(MessageBinding.from_list(hash['message']), MessageBinding.from_hash(hash['recipient']))
  end

  def as_json
    {
      kind: kind,
      message: message,
      recipient: recipient,
    }
  end
end
