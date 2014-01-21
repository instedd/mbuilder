class Pill
  include Rebindable
  include Hasheable

  def value_in(context)
    subclass_responsibility
  end

  def guid
    subclass_responsibility
  end

  def as_json
    subclass_responsibility
  end

  def rebind_table(from_table, to_table)
    # By default, do nothing
  end

  def rebind_field(from_field, to_table, to_field)
    # By default, do nothing
  end

  def empty?
    false
  end

  def self.kind
    kind = name.split("::").last.underscore
    kind = kind[0 .. -6] if kind.end_with?('_pill')
    kind
  end
end
