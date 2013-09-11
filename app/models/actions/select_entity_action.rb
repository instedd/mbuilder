class Actions::SelectEntityAction < Actions::TableFieldAction
  def execute(context)
    value = pill.value_in(context)
    context.select_entities(table, field, value)
  end
end
