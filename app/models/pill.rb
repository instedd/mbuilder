class Pill
  attr_accessor :kind
  attr_accessor :guid

  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def self.from_hash(hash)
    new hash['kind'], hash['guid']
  end

  def as_json
    {
      kind: kind,
      guid: guid,
    }
  end
end
