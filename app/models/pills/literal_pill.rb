class Pills::LiteralPill < Pill
  attr_reader :guid
  attr_reader :text

  def initialize(guid, text)
    @guid = guid
    @text = text
  end

  generate_equals :guid, :text

  def value_in(context)
    text.to_f_if_looks_like_number
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
