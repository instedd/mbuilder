class Pills::ImplicitPill < Pill
  attr_accessor :guid

  def initialize(guid)
    @guid = guid
  end

  def value_in(context)
    context.implicit_value(guid)
  end

  def self.from_hash(hash)
    new hash['guid']
  end
end
