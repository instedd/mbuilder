class InvalidValueException < Exception
  attr_reader :table_guid
  attr_reader :field_guid
  attr_reader :value

  def initialize(table_guid, field_guid, value)
    @table_guid = table_guid
    @field_guid = field_guid
    @value = value
  end
end
