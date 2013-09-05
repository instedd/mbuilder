class Pill
  def value_in(context)
    subclass_responsibility
  end

  def as_json
    {
      kind: kind,
      guid: guid
    }
  end

  def kind
    self.class.kind
  end

  def self.kind
    kind = name.split("::").last.underscore
    kind = kind[0 .. -6] if kind.end_with?('_pill')
    kind
  end

  def self.from_list(list)
    list.map do |hash|
      from_hash hash
    end
  end

  def self.from_hash(hash)
    kind = hash['kind']
    SuitableClassFinder.find_leaf_subclass_of(self,
      if_found: lambda{|pill| pill.from_hash hash},
      if_none: proc{raise "Unkonwn pill kind: #{kind}"}) do |subclass|
        subclass.kind == kind
      end
  end
end
