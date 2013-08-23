class Message
  attr_accessor :pieces

  def initialize(pieces)
    @pieces = pieces
  end

  def self.from_hash(hash)
    pieces = hash['pieces'].map do |piece|
      MessagePiece.from_hash(piece)
    end
    new pieces
  end
end
