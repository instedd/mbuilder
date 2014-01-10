class IterationEntity
  def initialize(properties)
    @properties = properties
  end

  def field_values(field, aggregate)
    [@properties[field]]
  end

  def save
    # Nothing to do
  end
end
