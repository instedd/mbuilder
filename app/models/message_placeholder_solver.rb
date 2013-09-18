class MessagePlaceholderSolver < PlaceholderSolver
  def initialize(message, trigger, match)
    @message = message
    @match = match
    @pieces = trigger.logic.message.pieces.select { |piece| piece.kind == 'placeholder' }
  end

  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      @message['from'].without_protocol
    else
      index = @pieces.index { |piece| piece.guid == guid }
      @match[index + 1]
    end
  end
end