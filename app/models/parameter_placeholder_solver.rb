class ParameterPlaceholderSolver < PlaceholderSolver
  def initialize(parameters, time)
    @parameters = parameters
    @time = time
  end

  def piece_value(guid, trigger)
    case guid
    when 'received_at'
      @time.strftime("%Y%m%d")
    else
      @parameters[trigger.parameters.detect {|parameter| parameter.guid == guid}.name] rescue nil
    end.to_f_if_looks_like_number
  end
end
