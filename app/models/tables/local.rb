class Tables::Local < Table
  attr_reader :name, :guid, :fields

  def initialize(name, guid, fields)
    @name = name
    @guid = guid
    @fields = fields
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], TableFields::Local.from_list(hash['fields'])
  end
end
