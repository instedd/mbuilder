class Pills::FieldValuePill < Pill
  attr_reader :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    #TODO move this into the creation and rebinding of the pill
    context.entity_field_values(context.application.table_of(guid).guid, guid)
  end

  def rebind_table(from_table, to_table)
    # nothing to do?
  end

  def rebind_field(from_field, to_table, to_field)
    @guid = to_field
  end

  def self.from_hash(hash)
    new hash['guid']
  end
end
