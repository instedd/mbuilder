class ParameterPlaceholderSolver < PlaceholderSolver
  def initialize(parameters)
    @parameters = parameters
  end

  def piece_value(guid, trigger)
    case guid
    when 'received_at'
      Time.parse(@message['timestamp']).strftime("%Y%m%d")
    else
      @parameters[trigger.parameters.detect {|parameter| parameter.guid == guid}.name] rescue nil
    end.to_f_if_looks_like_number
  end
end
