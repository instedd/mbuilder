class Actions::SendMessage < Action
  attr_accessor :message
  attr_accessor :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  generate_equals :message, :recipient

  def execute(context)
    message = (@message.map do |binding|
      values = Array(binding.value_in(context).user_friendly)
      values.join ", "
    end.map{|s| s.gsub("\u00A0", " ").strip}).join(" ").strip

    # TODO: maybe this is wrong
    message.gsub!(" .", ".")
    message.gsub!(" ,", ",")
    message.gsub!(" :", ":")
    message.gsub!(/"\s*(.+?)\s*"/, '"\1"')
    message.gsub!(/'\s*(.+?)\s*'/, '\'\1\'')

    recipients = @recipient.value_in(context).user_friendly
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
    message_pills = Pill.from_list(hash['message']).select { |p| !p.empty? }
    new(message_pills, Pill.from_hash(hash['recipient']))
  end

  def as_json
    {
      kind: kind,
      # We add an empty text pill at the end so the user can place the cursor there
      message: message.as_json,
      recipient: to_literal_if_text(recipient).as_json,
    }
  end

  private

  def to_literal_if_text(pill)
    # initially text pills were used to store the recipient
    # now literals pills are the way to go.
    # in order to avoid a data migration coupled to classes we lazy migrate data of the send message step.
    if pill.kind == 'text'
      Pills::LiteralPill.new(Guid.new.to_s, pill.guid)
    else
      pill
    end
  end
end
