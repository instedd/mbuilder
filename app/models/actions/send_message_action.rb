class Actions::SendMessageAction < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def execute(context)
    message = @message.map do |binding|
      solved = binding.solve(context)
      Array(solved).join ", "
    end.join " "

    # TODO: maybe this is wrong
    message.gsub!(" .", ".")
    message.gsub!(" ,", ",")

    recipients = @recipient.solve(context)
    Array(recipients).each do |recipient|
      context.send_message(recipient, message)
    end
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
