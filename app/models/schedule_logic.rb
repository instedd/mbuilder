class ScheduleLogic
  attr_accessor :schedule
  attr_accessor :actions

  def initialize(schedule, actions)
    @schedule = schedule
    @actions = actions
  end
end
