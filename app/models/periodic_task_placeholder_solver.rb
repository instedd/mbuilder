class PeriodicTaskPlaceholderSolver < ApplicationPlaceholderSolver

  def initialize(application, time)
    super(application)
    @time = time
  end

  def piece_value(guid, trigger)
    case guid
    when 'received_at'
      format_time @time
    else
      nil
    end
  end

end
