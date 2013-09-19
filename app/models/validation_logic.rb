class ValidationLogic
  include Rebindable

  attr_accessor :from
  attr_accessor :invalid_value
  attr_accessor :actions

  def initialize(from, invalid_value, actions)
    @from = from
    @invalid_value = invalid_value
    @actions = actions
  end

  def execute(context)
    actions.each do |action|
      action.execute(context)
    end
  end

  def rebind_table(from_table, to_table)
    actions.each do |action|
      action.rebind_table(from_table, to_table)
    end
  end

  def rebind_field(from_field, to_table, to_field)
    actions.each do |action|
      action.rebind_field(from_field, to_table, to_field)
    end
  end
end
