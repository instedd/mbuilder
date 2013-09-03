class Message
  attr_accessor :from
  attr_accessor :pieces

  def initialize(from, pieces)
    @from = from
    @pieces = pieces
  end

  def compile
    pattern = "\\A\\s*"
    pieces.each_with_index do |piece, i|
      pattern << "\\s+" if i > 0
      piece.append_pattern(pattern, i, pieces.length)
    end
    pattern << "\\s*\\Z"
    pattern
  end

  def self.from_hash(hash)
    pieces = hash['pieces'].map do |piece|
      MessagePiece.from_hash(piece)
    end
    new hash['from'], pieces
  end
end
