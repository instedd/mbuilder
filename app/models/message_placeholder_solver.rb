class MessagePlaceholderSolver < PlaceholderSolver
  def initialize(message, trigger, match)
    @message = message
    @match = match
    @pieces = trigger.message.pieces.select { |piece| piece.kind == 'placeholder' }
  end

  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      @message['from'].without_protocol
    when 'received_at'
      Time.parse(@message['timestamp']).strftime("%Y%m%d")
    else
      index = @pieces.index { |piece| piece.guid == guid }
      @match[index + 1]
    end.to_f_if_looks_like_number
  end
end
