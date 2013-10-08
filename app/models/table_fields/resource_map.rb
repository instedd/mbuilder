class TableFields::ResourceMap < TableField
  attr_reader :name, :guid, :valid_values, :id

  def initialize(name, guid, valid_values, id)
    @name = name
    @guid = guid
    @valid_values = valid_values
    @id = id
  end

  def as_json
    super.merge(id: id)
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values'], hash['id']
  end
end
