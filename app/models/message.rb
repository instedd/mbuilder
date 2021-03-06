class Message
  attr_reader :from
  attr_reader :pieces
  attr_reader :pattern

  def initialize(from, pieces)
    @from = from
    @pieces = pieces
    initialize_pattern
  end

  def initialize_pattern
    @pattern = "\\A\\s*"
    pieces.select(&:present?).each_with_index do |piece, i|
      @pattern << "\\s+" if i > 0
      piece.append_pattern(@pattern, i, pieces.length)
    end
    @pattern << "\\s*\\Z"
    @pattern = /#{@pattern}/i
  end

  def match incoming_message
    @pattern.match incoming_message
  end

  generate_equals :from, :pieces, :pattern

  def self.from_hash(hash)
    pieces = MessagePiece.from_list(hash['pieces'])
    new hash['from'], pieces
  end
end
