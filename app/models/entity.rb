class Entity
  def initialize(context, table, id)
    @context = context
    @table = table
    @id = id
    @properties = {}
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def save
    if @id
      @context.update @table, @id, @properties
    else
      @context.insert @table, @properties
    end
  end
end
