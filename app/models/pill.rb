class Pill
  attr_accessor :kind
  attr_accessor :guid

  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def value_in(context)
    if kind == 'implicit'
      context.implicit_value(guid)
    else
      context.piece_value(guid)
    end
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
