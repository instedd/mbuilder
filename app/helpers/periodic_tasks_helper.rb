module PeriodicTasksHelper
  def periodic_task_to_angular(application, trigger)

    str = ""
    str << "applicationId=#{trigger.application_id.to_json_oj};"
    str << "id=#{trigger.id.to_json_oj};"
    str << "name=#{trigger.name.to_json_oj};"

    if trigger.actions
      str << "actions=#{trigger.actions.map(&:as_json).to_json_oj};"
    else
      str << "actions=[];"
    end

    str << "scheduleTime = #{trigger.schedule.start_time.strftime("%H:%M:%S").to_json_oj};"

    if application.tables
      str << "tables=#{application.tables.map(&:as_json).to_json_oj};"
    else
      str << "tables=[];"
    end

    str << "external_services=#{application.external_services.map(&:as_json).to_json_oj};"

    db = application.simulate_triggers_execution_excluding trigger

    str << "db=#{db.to_json_oj};"
    str
  end
end
