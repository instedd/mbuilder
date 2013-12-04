module ValidationTriggersHelper
  def validation_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json_oj};"
    str << "field_guid=#{trigger.field_guid.to_json_oj};"
    str << "from=#{trigger.default_from_number.to_json_oj};"
    str << "invalid_value=#{trigger.default_invalid_value_label.to_json_oj};"

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
