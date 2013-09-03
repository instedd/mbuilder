class MessageBinding
  attr_reader :kind
  attr_reader :guid

  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def solve(context)
    case kind
    when 'text'
      guid
    when 'message_piece'
      context.piece_value(guid)
    when 'implicit'
      context.implicit_value(guid)
    when 'field'
      table, field = guid.split ';'
      values = context.entity_field_values(table, field)
    else
      raise "Uknown message binding kind: #{kind}"
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

  def to_s
    "#{kind}: #{guid}"
  end
end
