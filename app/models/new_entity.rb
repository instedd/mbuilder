class NewEntity
  attr_accessor :group_by

  def initialize(context, table)
    @context = context
    @table = table
    @properties = {}
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def empty?
    false
  end

  def save
    @context.insert @table, @properties
  end

  def new?
    true
  end

  def table
    @table
  end

  def field_values(field, aggregate)
    @context.select_table_field(@table, [], field, group_by, aggregate)
  end
end
