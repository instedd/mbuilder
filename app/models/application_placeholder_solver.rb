class ApplicationPlaceholderSolver < PlaceholderSolver
  def initialize(application)
    @application = application
  end

protected

  def format_time(time)
    ActiveSupport::TimeZone.new(@application.time_zone).utc_to_local(time.utc).strftime("%Y%m%d")
  end
end
