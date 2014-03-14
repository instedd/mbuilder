class Actions::CreateEntity < Actions::TableField
  def execute(context)
    value = pill.value_in(context)
    value = value.to_single

    value = value.to_f_if_looks_like_number

    context.check_valid_value!(table, field, value)

    entity = context.new_entity(table)
    entity[field] = value
  end
end
