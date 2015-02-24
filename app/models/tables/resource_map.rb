class Tables::ResourceMap < Table
  attr_reader :name, :guid, :fields, :id

  def initialize(name, guid, fields, id)
    @name = name
    @guid = guid
    @fields = fields
    @id = id
  end

  generate_equals :name, :guid, :fields, :id

  def as_json
    super.merge(id: id, protocol: %w(query update insert), readonly: true)
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableFields::ResourceMap.from_list(hash['fields']), hash['id']
  end

  def select_field_in(context, restrictions, field, group_by, aggregate)
    mapped_restrictions = restrictions.map(&:clone).each do |restriction|
      f = find_field(restriction[:field])
      restriction[:field] = f.id
      restriction[:modifier] = f.modifier if f.modifier.present?
    end
    context.select_resource_map_field(id, mapped_restrictions, find_field(field), group_by, aggregate)
  end

  def insert_in(context, properties)
    mapped_properties = Hash[properties.map do |field_guid, value|
      [find_field(field_guid).id, value]
    end]
    context.insert_in_resource_map id, mapped_properties
  end

  def each_value(context, restrictions, group_by, &block)
    mapped_restrictions = restrictions.map(&:clone).each do |restriction|
      restriction[:field] = find_field(restriction[:field]).id
    end
    context.each_resource_map_value(id, mapped_restrictions, group_by, &block)
  end

  def update_many(context, restrictions, properties)
    mapped_properties = Hash[properties.map do |field_guid, value|
      [find_field(field_guid).id, value]
    end]
    context.update_many_local(self, restrictions, mapped_properties)
  end

  private

  def resource_map_api
    @resource_map_api ||= ResourceMap::Api.trusted(application.user.email, ResourceMap::Config.url, ResourceMap::Config.use_https)
  end
end
