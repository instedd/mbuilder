module ValidationTriggersHelper
  def validation_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "field_guid=#{trigger.field_guid.to_json};"
    str << "from=#{trigger.generate_from_number.to_json};"
    str << "invalid_value=#{trigger.generate_invalid_value.to_json};"

    if trigger.actions
      str << "actions=#{trigger.actions.map(&:as_json).to_json};"
    else
      str << "actions=[];"
    end

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
