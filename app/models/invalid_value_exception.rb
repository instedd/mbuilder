class InvalidValueException < Exception
  attr_reader :field_guid
  attr_reader :value

  def initialize(field_guid, value)
    @field_guid = field_guid
    @value = value
  end
end
