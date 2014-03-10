class Actions::StoreEntityValue < Actions::TableField
  attr_accessor :create_or_update

  generate_equals :pill, :table, :field, :create_or_update

  def initialize(table, field, pill, create_or_update)
    super(table, field, pill)
    @create_or_update = create_or_update
  end

  def execute(context)
    value = pill.value_in(context)
    value = value.first if (value.is_an? Array) && value.one?

    value = value.to_f_if_looks_like_number

    context.check_valid_value!(table, field, value)

    entity = context.entity(table)
    if entity.empty? && create_or_update
      entity.create_entity_matching_restrictions
    end
    entity[field] = value
  end

  def as_json
    super.tap do |s|
      s[:create_or_update] = create_or_update
    end
  end

  def self.from_hash(hash)
    new hash['table'], hash['field'], Pill.from_hash(hash['pill']), hash['create_or_update']
  end
end
