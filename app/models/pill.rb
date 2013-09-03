class Pill
  attr_accessor :kind
  attr_accessor :guid

  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def value_in(context)
    case kind
    when 'text'
      guid
    when 'implicit'
      context.implicit_value(guid)
    when 'piece'
      context.piece_value(guid)
    when 'field'
      table, field = guid.split ';'
      context.entity_field_values(table, field)
    else
      raise "Unkonwn pill kind: #{kind}"
    end
  end

  def self.from_list(list)
    list.map do |hash|
      from_hash hash
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
