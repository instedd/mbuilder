class EntitySelection
  def initialize(context, table)
    @context = context
    @table = table
    @restrictions = []
    @properties = {}
  end

  def eq(field, value)
    @restrictions.push op: :eq, field: field, value: value
    self
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def save
    @context.update_many(@table, @properties) do |search|
      @restrictions.each do |restriction|
        case restriction[:op]
        when :eq
          search.filter :term, restriction[:field] => restriction[:value]
        end
      end
    end
  end
end
