class Pills::ResultPill < Pill
  attr_reader :guid
  attr_reader :name

  def initialize(guid, name)
    @guid = guid
    @name = name
  end

  generate_equals :guid, :name

  def value_in(context)
    # FIXME: add result values to execution context
  end

  def self.from_hash(hash)
    new hash['guid'], hash['name']
  end

  def as_json
    {
      kind: kind,
      guid: guid,
      name: name
    }
  end
end
