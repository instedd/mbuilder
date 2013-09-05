class Pills::PlaceholderPill < Pill
  attr_accessor :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    context.piece_value(guid)
  end

  def self.from_hash(hash)
    new hash['guid']
  end

  def self.kind
    # TODO: this will be removed once this kind of pill is renamed to 'placeholder'
    'piece'
  end
end
