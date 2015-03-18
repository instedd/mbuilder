class IterationEntity
  def initialize(context, entity, properties)
    @context = context
    @entity = entity
    @properties = properties
    @written_properties = {}
  end

  def field_values(field, aggregate)
    @context.field_values(@entity, @properties, field, aggregate)
  end

  def save
    return if @written_properties.empty?

    @context.update_many(table, restrictions, @written_properties)
  end

  def empty?
    false
  end

  def new?
    @entity.new?
  end

  def table
    @entity.table
  end

  def restrictions
    # use all entity values as restriction
    # used to update the entity in a foreach
    # in case a value is updated, use that as restriction
    @properties.map do |field_guid, value|
      { op: :eq, field: field_guid, value: value  }
    end
  end

  def []=(field, value)
    @written_properties[field.to_s] = value
  end

end
