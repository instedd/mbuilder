class MessagePiece
  attr_accessor :kind
  attr_accessor :text
  attr_accessor :guid

  def initialize(kind, text, guid)
    @kind = kind
    @text = text
    @guid = guid
  end

  def as_json
    {
      kind: kind,
      text: text,
      guid: guid,
    }
  end

  def self.from_hash(hash)
    new hash['kind'], hash['text'], hash['guid']
  end
end
