Tire::Configuration.wrapper Hash

module Tire
  def self.parse_date(date)
    Time.parse(date)
  end

  def self.format_date(date)
    date.utc.iso8601
  end
end
