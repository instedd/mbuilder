class Actions::StoreEntityValueAction < Actions::TableFieldAction
  def execute(context)
    value = pill.value_in(context)

    context.check_valid_value!(table, field, value)

    entity = context.entity(table)
    entity[field] = value
  end
end
