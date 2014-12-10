class Tables::Hub < Table
  attr_reader :name, :guid, :fields, :path

  def initialize(name, guid, fields, path)
    @name = name
    @guid = guid
    @fields = fields
    @path = path
  end

  generate_equals :name, :guid, :fields, :path

  def as_json
    super.merge(path: path, readonly: true)
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableFields::Hub.from_list(hash['fields']), hash['path']
  end

  def select_field_in(context, restrictions, field, group_by, aggregate)
    context.select_hub_field(self, restrictions_to_hub(restrictions), find_field(field), group_by, aggregate)
  end

  def insert_in(context, properties)
    mapped_properties = properties_to_hub(properties)
    context.insert_in_hub(path, mapped_properties)
  end

  def each_value(context, restrictions, group_by, &block)
    context.each_hub_value(self, restrictions_to_hub(restrictions), group_by, &block)
  end

  def assign_value_to_entity_field(context, entity, field, value)
    context.assign_hub_value_to_entity(entity, field, value)
  end

  def restrictions_to_hub(restrictions)
    restrictions.each_with_object({}) do |restriction, hash|
      hash[find_field(restriction[:field]).name] = restriction[:value].user_friendly
    end
  end

  def properties_to_hub(properties)
    Hash[properties.map do |field_guid, value|
      [find_field(field_guid).name, value.user_friendly]
    end]
  end

  def hub_entity_to_mbuilder_hash(hub_entity)
    fields.each_with_object({}) do |field, hash|
      hash[field.guid] = hub_entity[field.name]
    end
  end
end
