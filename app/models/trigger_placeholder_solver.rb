class TriggerPlaceholderSolver < PlaceholderSolver
  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      trigger.logic.message.from
    else
      trigger.logic.message.pieces.find { |piece| piece.guid == guid }.text
    end
  end
end
