module Rebindable
  def rebind_table(from_table, to_table)
    subclass_responsibility
  end

  def rebind_field(from_field, to_table, to_field)
    subclass_responsibility
  end
end