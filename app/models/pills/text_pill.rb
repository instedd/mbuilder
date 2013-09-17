class Pills::TextPill < Pill
  attr_reader :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    guid
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
