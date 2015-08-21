class ParameterPlaceholderSolver < ApplicationPlaceholderSolver
  def initialize(application, parameters, time)
    super(application)
    @parameters = parameters
    @time = time
  end

  def piece_value(guid, trigger)
    case guid
    when 'received_at'
      format_time @time
    else
      @parameters[trigger.parameters.detect {|parameter| parameter.guid == guid}.name] rescue nil
    end.to_f_if_looks_like_number
  end
end
