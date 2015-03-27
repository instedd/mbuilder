module MessageTriggersHelper
  def message_trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json_oj};"
    str << "name=#{trigger.name.to_json_oj};"

    if trigger.message
      from = trigger.message.from
      from = trigger.default_from_number if from.blank?

      # We add an empty text pill at the end so the user can place the cursor there
      pieces = (trigger.message.pieces + [MessagePiece.new("text", "", Guid.new.to_s)]).map(&:as_json).to_json_oj

      str << "from=#{from.to_json_oj};"
      str << "pieces=#{pieces};"
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

    str << "external_services=#{application.external_services.map(&:as_json).to_json_oj};"

    db = application.simulate_triggers_execution_excluding trigger

    str << "db=#{db.to_json_oj};"
    str
  end
end
