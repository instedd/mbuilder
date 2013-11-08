class Actions::StoreEntityValue < Actions::TableField
  def execute(context)
    value = pill.value_in(context)
    value = value.first if (value.is_an? Array) && value.one?

    value = value.to_f_if_looks_like_number

    context.check_valid_value!(table, field, value)

    entity = context.entity(table)
    entity[field] = value
  end
end
