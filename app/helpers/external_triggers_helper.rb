module ExternalTriggersHelper
  def external_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json_oj};"
    str << "name=#{trigger.name.to_json_oj};"
    str << "enabled=#{trigger.enabled.to_json_oj};"
    str << "authMethod=#{trigger.auth_method.to_json_oj};"

    if trigger.parameters
      str << "parameters=#{trigger.parameters.map(&:as_json).to_json_oj};"
    else
      str << "parameters=[];"
    end

    if trigger.actions
      str << "actions=#{trigger.actions.map(&:as_json).to_json_oj};"
    else
      str << "actions=[];"
    end

    if application.tables
      str << "tables=#{application.tables.map(&:as_json).to_json_oj};"
    else
      str << "tables=[];"
    end

    db = application.simulate_triggers_execution_excluding trigger

    str << "db=#{db.to_json_oj};"
    str
  end
end
