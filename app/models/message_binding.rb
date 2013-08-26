class MessageBinding
  def initialize(kind, guid)
    @kind = kind
    @guid = guid
  end

  def self.from_list(list)
    list.map do |hash|
      from_hash hash
    end
  end

  def self.from_hash(hash)
    new hash['kind'], hash['guid']
  end
end
