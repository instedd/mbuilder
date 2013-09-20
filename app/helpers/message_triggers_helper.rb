module MessageTriggersHelper
  def message_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json};"
    str << "name=#{trigger.name.to_json};"

    if trigger.message
      from = trigger.message.from
      from = trigger.generate_from_number if from.blank?

      str << "from=#{from.to_json};"
      str << "pieces=#{trigger.message.pieces.map(&:as_json).to_json};"
      str << "actions=#{trigger.actions.map(&:as_json).to_json};"
    else
      str << "pieces=[];"
      str << "actions=[];"
      str << "from=#{trigger.generate_from_number.to_json};"
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
