class Logic
  include Rebindable

  attr_accessor :message
  attr_accessor :actions

  def initialize(message, actions)
    @message = message
    @actions = actions
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
