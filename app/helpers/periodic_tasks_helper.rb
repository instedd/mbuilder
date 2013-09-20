module PeriodicTasksHelper
  def periodic_task_to_angular(application, trigger)

    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json};"
    str << "name=#{trigger.name.to_json};"

    if trigger.actions
      str << "actions=#{trigger.actions.map(&:as_json).to_json};"
    else
      str << "actions=[];"
    end

    str << "scheduleTime = #{trigger.schedule.start_time.strftime("%H:%M:%S").to_json};"

    if application.tables
      str << "tables=#{application.tables.map(&:as_json).to_json};"
    else
      str << "tables=[];"
    end

    db = application.simulate_triggers_execution_excluding trigger

    str << "db=#{db.to_json};"
    str
  end
end
