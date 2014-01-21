class Pills::FieldValuePill < Pill
  attr_reader :guid
  attr_reader :aggregate

  def initialize(guid, aggregate)
    @guid = guid
    @aggregate = aggregate
  end

  generate_equals :guid, :aggregate

  def value_in(context)
    context.entity_field_values(guid, aggregate)
  end

  def rebind_table(from_table, to_table)
    # nothing to do?
  end

  def rebind_field(from_field, to_table, to_field)
    @guid = to_field
  end

  def self.from_hash(hash)
    new hash['guid'], hash['aggregate']
  end

  def as_json
    {
      kind: kind,
      guid: guid,
      aggregate: aggregate,
    }
  end
end
