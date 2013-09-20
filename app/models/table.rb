class Table
  attr_accessor :name
  attr_accessor :guid
  attr_accessor :fields

  def initialize(name, guid, fields)
    @name = name
    @guid = guid
    @fields = fields
  end

  def find_field(guid)
    @fields.find { |field| field.guid == guid }
  end

  def as_json
    {
      name: name,
      guid: guid,
      fields: fields.map(&:as_json)
    }
  end

  def self.from_list(list)
    list.map { |hash| Table.from_hash(hash) }
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableField.from_list(hash['fields'])
  end
end
