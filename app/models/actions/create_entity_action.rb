class Actions::CreateEntityAction < Action
  attr_accessor :pill
  attr_accessor :table
  attr_accessor :field

  def initialize(table, field, pill)
    @table = table
    @field = field
    @pill = pill
  end

  def execute(context)
    entity = context.new_entity(table)
    entity[field] = pill.value_in(context)
  end

  def self.from_hash(hash)
    new hash['table'], hash['field'], Pill.from_hash(hash['pill'])
  end

  def as_json
    {
      kind: kind,
      table: table,
      field: field,
      pill: pill.as_json,
    }
  end
end
