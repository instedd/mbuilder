class NullPlaceholderSolver < PlaceholderSolver
  def piece_value(guid, trigger)
    nil
  end
end
