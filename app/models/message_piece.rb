class MessagePiece
  attr_accessor :kind
  attr_accessor :text
  attr_accessor :guid

  def initialize(kind, text, guid)
    @kind = kind
    @text = text
    @guid = guid
  end

  def append_pattern(pattern)
    if kind == "text"
      pattern << Regexp.escape(text)
    else
      pattern << "("
      case infer_pattern
      when :float
        pattern << "\\d+\\.\\d+"
      when :integer
        pattern << "\\d+"
      when :multiple_word
        pattern << "[\\w\\s]+"
      when :single_word
        pattern << "\\w+"
      end
      pattern << ")"
    end
  end

  def infer_pattern
    self.class.infer_pattern(text)
  end

  def self.infer_pattern(text)
    case
    when text =~ /\d+\.\d+/
      :float
    when text =~ /\d+/
      :integer
    when text.include?(' ')
      :multiple_word
    else
      :single_word
    end
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
