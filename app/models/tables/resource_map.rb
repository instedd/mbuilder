class Tables::ResourceMap < Table
  attr_reader :name, :guid, :fields, :id

  def as_json
    super.merge(id: id, readonly: true)
  end

  def initialize(name, guid, fields, id)
    @name = name
    @guid = guid
    @fields = fields
    @id = id
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableFields::ResourceMap.from_list(hash['fields']), hash['id']
  end

  def select_field_in(context, restrictions, field, group_by, aggregate)
    mapped_restrictions = restrictions.clone.each do |restriction|
      restriction[:field] = find_field(restriction[:field]).id
    end
    context.select_resource_map_field(id, mapped_restrictions, find_field(field).id, group_by, aggregate)
  end
end
