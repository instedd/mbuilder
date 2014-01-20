class IterationEntity
  def initialize(context, entity, properties)
    @context = context
    @entity = entity
    @properties = properties
  end

  def field_values(field, aggregate)
    if !@entity.group_by || @entity.group_by == field
      return [@properties[field]]
    end

    entity = @entity.clone
    @properties.each do |name, value|
      entity.eq(name, value)
    end
    entity.field_values(field, aggregate)
  end

  def save
    # Nothing to do
  end
end
