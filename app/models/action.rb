class Action
  def self.from_list(list)
    list.map do |hash|
      from_hash hash
    end
  end

  def self.from_hash(hash)
    kind = hash['kind']
    SuitableClassFinder.find_leaf_subclass_of(self,
      if_found: proc{|action| action.from_hash hash},
      if_none: proc{raise "Unknown action for '#{kind}' kind"}) {|subclass| subclass.kind == kind}
  end

  def self.kind
    kind = name.split("::").last.underscore
    kind = kind[0 .. -8] if kind.end_with?('_action')
    kind
  end

  def kind
    self.class.kind
  end
end
