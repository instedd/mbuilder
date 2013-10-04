class TriggerPlaceholderSolver < PlaceholderSolver
  def piece_value(guid, trigger)
    case guid
    when 'phone_number'
      trigger.message.from
    else
      trigger.message.pieces.find { |piece| piece.guid == guid }.text
    end.normalize_for_elasticsearch
  end
end
