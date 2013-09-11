class Pills::FieldValuePill < Pill
  attr_reader :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    table, field = table_and_field
    context.entity_field_values(table, field)
  end

  def rebind_table(from_table, to_table)
    table, field = table_and_field
    if table == from_table
      @guid = "#{to_table};#{field}"
    end
  end

  def rebind_field(from_field, to_table, to_field)
    table, field = table_and_field
    if field == from_field
      @guid = "#{to_table};#{to_field}"
    else
      @guid = "#{to_table};#{field}"
    end
  end

  def self.from_hash(hash)
    new hash['guid']
  end

  def table_and_field
    guid.split ';'
  end
end
