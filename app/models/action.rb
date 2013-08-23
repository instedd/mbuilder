class Action
  def self.from_list(list)
    list.map do |hash|
      from_hash hash
    end
  end

  def self.from_hash(hash)
    kind = hash['kind']
    subclasses.each do |action|
      if action.kind == kind
        return action.from_hash hash
      end
    end

    raise "Unknown action for '#{kind}' kind"
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
