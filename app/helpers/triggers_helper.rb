module TriggersHelper
  def trigger_to_angular(application, trigger)
    str = ""
    str << "applicationId=#{trigger.application_id.to_json};"
    str << "id=#{trigger.id.to_json};"
    str << "name=#{trigger.name.to_json};"

    if trigger.logic
      str << "pieces=#{trigger.logic.message.pieces.map(&:as_json).to_json};"
      str << "actions=#{trigger.logic.actions.map(&:as_json).to_json};"
    else
      str << "pieces=[];"
      str << "actions=[];"
    end


    if application.tables
      str << "tables=#{application.tables.map(&:as_json).to_json};"
    else
      str << "tables=[];"
    end
    str
  end

  def actions_to_angular(actions)
  end
end
