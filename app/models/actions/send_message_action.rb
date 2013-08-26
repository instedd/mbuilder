class Actions::SendMessageAction < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def self.from_hash(hash)
    new(MessageBinding.from_list(hash['message']), hash['recipient'])
  end

  def as_json
    {
      kind: kind,
      message: message,
      recipient: recipient,
    }
  end
end
