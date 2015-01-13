class PeriodicTaskPlaceholderSolver < PlaceholderSolver

  def initialize(time)
    @time = time
  end

  def piece_value(guid, trigger)
    case guid
    when 'received_at'
      @time.strftime("%Y%m%d")
    else
      nil
    end
  end

end
