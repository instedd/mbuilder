class TriggerPlaceholderSolver < PlaceholderSolver
  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      trigger.message.from
    else
      trigger.message.pieces.find { |piece| piece.guid == guid }.text
    end.to_f_if_looks_like_number
  end
end
