class NewEntity
  def initialize(context, table)
    @context = context
    @table = table
    @properties = {}
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def save
    @context.insert @table, @properties
  end
end
