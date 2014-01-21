class Pills::PlaceholderPill < Pill
  attr_reader :guid

  def initialize(guid)
    @guid = guid
  end

  generate_equals :guid

  def value_in(context)
    context.piece_value(guid)
  end

  def self.from_hash(hash)
    new hash['guid']
  end

  def as_json
    {
      kind: kind,
      guid: guid,
    }
  end
end
