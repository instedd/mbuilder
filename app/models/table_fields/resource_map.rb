class TableFields::ResourceMap < TableField
  attr_reader :name, :guid, :id, :value, :kind
  attr_accessor :valid_values

  def initialize(name, guid, valid_values, id, kind, value)
    @name = name
    @guid = guid
    @valid_values = valid_values
    @id = id
    @kind = kind
    @value = value
  end

  def as_json
    super.merge(id: id, kind: kind, value: value)
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values'], hash['id'], hash['kind'], hash['value']
  end
end
