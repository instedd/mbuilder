class Actions::CreateEntity < Actions::TableField
  def execute(context)
    value = pill.value_in(context)
    value = value.first if (value.is_an? Array) && value.one?

    context.check_valid_value!(table, field, value)

    entity = context.new_entity(table)
    entity[field] = value
  end
end
