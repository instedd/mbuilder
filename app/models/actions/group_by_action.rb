class Actions::GroupByAction < Action

  def initialize(table, field)
    @table = table
    @field = field
  end

  def execute(context)
    context.group_by(@table, @field)
  end

  def rebind_table(from_table, to_table)
    @table = to_table if @table == from_table
  end

  def rebind_field(from_field, to_table, to_field)
    if @field == from_field
      @table = to_table
      @field = to_field
    end
  end

  def as_json
    {
      kind: kind,
      table: @table,
      field: @field
    }
  end

  def self.from_hash(hash)
    new hash['table'], hash['field']
  end
end
