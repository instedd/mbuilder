class Pills::NewPill < Pill
  def initialize()
  end

  def value_in(context)
    nil
  end

  def empty?
    true
  end

  def self.from_hash(hash)
    new
  end

  def as_json
    {
      kind: kind,
    }
  end
end
