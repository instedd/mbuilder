class Pills::LiteralPill < Pill
  attr_reader :guid
  attr_reader :text

  def initialize(guid, text)
    @guid = guid
    @text = text
  end

  def value_in(context)
    text
  end

  def self.from_hash(hash)
    new hash['guid'], hash['text']
  end

  def as_json
    {
      kind: kind,
      guid: guid,
      text: text
    }
  end
end
