class Tables::Local < Table
  attr_reader :name, :guid, :fields

  def initialize(name, guid, fields)
    @name = name
    @guid = guid
    @fields = fields
  end

  generate_equals :name, :guid, :fields

  def as_json
    super.merge(protocol: %w(query update insert))
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableFields::Local.from_list(hash['fields'])
  end

  def select_field_in(context, restrictions, field, group_by, aggregate)
    context.select_local_field(guid, restrictions, field, group_by, aggregate)
  end

  def insert_in(context, properties)
    context.insert_local(guid, properties)
  end

  def each_value(context, restrictions, group_by, &block)
    context.each_local_value(guid, restrictions, group_by, &block)
  end

  def update_many(context, restrictions, properties)
    context.update_many_local(self, restrictions, properties)
  end
end
