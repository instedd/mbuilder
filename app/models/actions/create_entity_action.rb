class Actions::CreateEntityAction < Actions::TableFieldAction
  def execute(context)
    entity = context.new_entity(table)
    entity[field] = pill.value_in(context)
  end
end
