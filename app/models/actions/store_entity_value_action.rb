class Actions::StoreEntityValueAction < Actions::TableFieldAction
  def execute(context)
    entity = context.entity(table)
    entity[field] = pill.value_in(context)
  end
end
