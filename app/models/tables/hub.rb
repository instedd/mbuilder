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
    # mapped_restrictions = restrictions.map(&:clone).each do |restriction|
    #   f = find_field(restriction[:field])
    #   restriction[:field] = f.id
    #   restriction[:modifier] = f.modifier if f.modifier.present?
    # end
    # context.select_resource_map_field(id, mapped_restrictions, find_field(field), group_by, aggregate)
  end

  def insert_in(context, properties)
    # mapped_properties = Hash[properties.map do |field_guid, value|
    #   [find_field(field_guid).id, value]
    # end]
    # context.insert_in_resource_map id, mapped_properties
  end

  def each_value(context, restrictions, group_by, &block)
    # mapped_restrictions = restrictions.map(&:clone).each do |restriction|
    #   restriction[:field] = find_field(restriction[:field]).id
    # end
    # context.each_resource_map_value(id, mapped_restrictions, group_by, &block)
  end

  def assign_value_to_entity_field(context, entity, field, value)
    # context.assign_resource_map_value_to_entity(entity, field, value)
  end

  private

  def hub_api
    @hub_api ||= HubClient::Api.trusted(application.user.email)
  end
end
