class Actions::SelectAllEntitiesAction < Action
  attr_accessor :table

  def initialize(table)
    @table = table
  end

  def execute(context)
    # value = pill.value_in(context)
    # context.select_entities(table, field, value)
  end

  def self.from_hash(hash)
    new hash['table']
  end

  def as_json
    {
      table: table,
    }
  end
end
