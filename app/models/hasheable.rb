module Hasheable
  def kind
    self.class.kind
  end

  module ClassMethods
    def from_list(list)
      list.map do |hash|
        from_hash hash
      end
    end

    def from_hash(hash)
      kind = hash['kind']
      SuitableClassFinder.find_leaf_subclass_of(self,
        if_found: lambda{|subclass| subclass.from_hash hash},
        if_none: proc{raise "Unknown #{name.underscore} for '#{kind}' kind"}) do |subclass|
          subclass.kind == kind
        end
    end

    def kind
      name.split("::").last.underscore
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end