class Message
  attr_accessor :pieces

  def initialize(pieces)
    @pieces = pieces
  end

  def compile
    pattern = "\\A\\s*"
    pieces.each_with_index do |piece, i|
      pattern << "\\s+" if i > 0
      piece.append_pattern(pattern)
    end
    pattern << "\\s*\\Z"
    pattern
  end

  def self.from_hash(hash)
    pieces = hash['pieces'].map do |piece|
      MessagePiece.from_hash(piece)
    end
    new pieces
  end
end
