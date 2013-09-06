class Actions::StoreEntityValueAction < Action
  include Actions::TableFieldAction

  def execute(context)
    entity = context.entity(table)
    entity[field] = pill.value_in(context)
  end
end
