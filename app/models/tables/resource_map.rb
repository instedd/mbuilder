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
end
