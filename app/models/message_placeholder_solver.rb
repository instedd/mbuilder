class MessagePlaceholderSolver < ApplicationPlaceholderSolver
  def initialize(application, message, trigger, match)
    super(application)
    @message = message
    @match = match
    @pieces = trigger.message.pieces.select { |piece| piece.kind == 'placeholder' }
  end

  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      @message['from'].without_protocol
    when 'received_at'
      format_time Time.parse(@message['timestamp'])
    else
      index = @pieces.index { |piece| piece.guid == guid }
      @match[index + 1]
    end.to_f_if_looks_like_number
  end
end
