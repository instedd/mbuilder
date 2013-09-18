class TableField
  attr_accessor :name
  attr_accessor :guid
  attr_accessor :valid_values

  def initialize(name, guid, valid_values)
    @name = name
    @guid = guid
    @valid_values = valid_values
  end

  def as_json
    {
      name: name,
      guid: guid,
      valid_values: valid_values,
    }
  end

  def self.from_list(list)
    list.map { |hash| TableField.from_hash(hash) }
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values']
  end
end
