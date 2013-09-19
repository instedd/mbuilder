class Actions::CreateEntityAction < Actions::TableFieldAction
  def execute(context)
    value = pill.value_in(context)

    context.check_valid_value!(table, field, value)

    entity = context.new_entity(table)
    entity[field] = value
  end
end
