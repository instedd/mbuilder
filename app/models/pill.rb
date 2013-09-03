class Pill
  attr_accessor :kind
  attr_accessor :guid

  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def value_in(context)
    case kind
    when 'implicit'
      context.implicit_value(guid)
    when 'piece'
      context.piece_value(guid)
    else
      raise "Unkonwn pill kind: #{kind}"
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
