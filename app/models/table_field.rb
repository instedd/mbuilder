class TableField
  attr_accessor :name
  attr_accessor :guid

  def initialize(name, guid)
    @name = name
    @guid = guid
  end

  def as_json
    {
      name: name,
      guid: guid,
    }
  end

  def self.from_list(list)
    list.map { |hash| TableField.from_hash(hash) }
  end

  def self.from_hash(hash)
    new hash['name'], hash['guid']
  end
end
