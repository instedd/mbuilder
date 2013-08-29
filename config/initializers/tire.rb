Tire::Configuration.wrapper Hash

module Tire
  DateFormat = "%Y%m%dT%H%M%S.%L%z"

  def self.parse_date(date)
    Time.zone.parse(date)
  end

  def self.format_date(date)
    date.strftime DateFormat
  end
end
