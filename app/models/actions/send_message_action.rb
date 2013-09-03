class Actions::SendMessageAction < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def execute(context)
    message = @message.map do |binding|
      value = binding.value_in(context)
      Array(value).join ", "
    end.join " "

    # TODO: maybe this is wrong
    message.gsub!(" .", ".")
    message.gsub!(" ,", ",")

    recipients = @recipient.value_in(context)
    Array(recipients).each do |recipient|
      context.send_message(recipient, message)
    end
  end

  def self.from_hash(hash)
    new(Pill.from_list(hash['message']), Pill.from_hash(hash['recipient']))
  end

  def as_json
    {
      kind: kind,
      message: message.as_json,
      recipient: recipient.as_json,
    }
  end
end
