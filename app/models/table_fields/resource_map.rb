class TableFields::ResourceMap < TableField
  attr_reader :name, :guid, :id, :value, :kind, :modifier
  attr_accessor :valid_values

  def initialize(name, guid, valid_values, id, kind, value, modifier)
    @name = name
    @guid = guid
    @valid_values = valid_values
    @id = id
    @kind = kind
    @value = value
    @modifier = modifier
  end

  def as_json
    super.merge(id: id, kind: kind, value: value, modifier: modifier)
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values'], hash['id'], hash['kind'], hash['value'], hash['modifier']
  end
end
