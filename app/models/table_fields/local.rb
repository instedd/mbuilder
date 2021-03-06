class TableFields::Local < TableField
  attr_reader :name, :guid
  attr_accessor :valid_values

  def initialize(name, guid, valid_values)
    @name = name
    @guid = guid
    @valid_values = valid_values
  end

  generate_equals :name, :guid, :valid_values

  def self.from_hash(hash)
    new hash['name'], hash['guid'], hash['valid_values']
  end
end
