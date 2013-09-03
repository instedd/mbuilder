class MessagePiece
  attr_accessor :kind
  attr_accessor :text
  attr_accessor :guid

  def initialize(kind, text, guid)
    @kind = kind
    @text = text
    @guid = guid
  end

  def append_pattern(pattern, index, total)
    case kind
    when "text"
      pattern << Regexp.escape(text)
    when "pill"
      pattern << "("
      case infer_pattern
      when :float
        pattern << "\\d+\\.\\d+"
      when :integer
        pattern << "\\d+"
      when :multiple_word
        pattern << ".+"
      when :single_word
        if index == total - 1
          pattern << ".+"
        else
          pattern << "\\S+"
        end
      end
      pattern << ")"
    else
      raise "Unknown message piece kind: #{kind}"
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

  def to_s
    case kind
    when 'text'
      text
    when 'pill'
      "{#{guid}}"
    else
      raise "Unknown message piece kind: #{kind}"
    end
  end
end
