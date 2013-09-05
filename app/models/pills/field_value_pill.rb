class Pills::FieldValuePill < Pill
  attr_reader :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    table, field = guid.split ';'
    context.entity_field_values(table, field)
  end

  def self.from_hash(hash)
    new hash['guid']
  end
end
