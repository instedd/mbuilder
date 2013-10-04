class InvalidValuePlaceholderSolver < PlaceholderSolver
  def initialize(solver, invalid_value)
    @solver = solver
    @invalid_value = invalid_value
  end

  def piece_value(guid, trigger)
    if guid == 'invalid_value'
      @invalid_value
    else
      @solver.piece_value(guid, trigger)
    end
  end
end
