class ScheduleLogic
  include Rebindable

  attr_accessor :schedule
  attr_accessor :actions

  def initialize(schedule, actions)
    @schedule = schedule
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
