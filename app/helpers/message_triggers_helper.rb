module MessageTriggersHelper
  def message_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json_oj};"
    str << "name=#{trigger.name.to_json_oj};"

    if trigger.message
      from = trigger.message.from
      from = trigger.default_from_number if from.blank?

      str << "from=#{from.to_json_oj};"
      str << "pieces=#{trigger.message.pieces.map(&:as_json).to_json_oj};"
      str << "actions=#{trigger.actions.map(&:as_json).to_json_oj};"
    else
      str << "pieces=[];"
      str << "actions=[];"
      str << "from=#{trigger.default_from_number.to_json_oj};"
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
