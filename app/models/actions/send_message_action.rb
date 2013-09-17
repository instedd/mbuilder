class Actions::SendMessageAction < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def execute(context)
    message = @message.map { |binding| binding.value_in(context) }.join(" ").strip

    # TODO: maybe this is wrong
    message.gsub!(" .", ".")
    message.gsub!(" ,", ",")
    message.gsub!(/"\s*(.+?)\s*"/, '"\1"')

    recipients = @recipient.value_in(context)
    Array(recipients).each do |recipient|
      context.send_message(recipient, message)
    end
  end

  def rebind_table(from_table, to_table)
    recipient.rebind_table(from_table, to_table)
    message.each do |binding|
      binding.rebind_table(from_table, to_table)
    end
  end

  def rebind_field(from_field, to_table, to_field)
    recipient.rebind_field(from_field, to_table, to_field)
    message.each do |binding|
      binding.rebind_field(from_field, to_table, to_field)
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
