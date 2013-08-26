class ExecutionContext
  attr_reader :application
  attr_reader :trigger
  attr_reader :message
  attr_reader :match

  def initialize(application, trigger, message, match)
    @application = application
    @trigger = trigger
    @message = message
    @match = match
    @entities = {}
    @pieces = @trigger.logic.message.pieces.select { |piece| piece.kind == 'pill' }
  end

  def new_entity(table)
    @entities[table] ||= Entity.new(self, table, nil)
  end

  def find_entity(table, field, value)
    search = application.tire_search(table)
    search.filter :term, field => value
    results = search.perform.results
    result = results[0]

    entity = Entity.new(self, table, result["_id"])
    @entities[table] ||= entity

    result["_source"]["properties"].each do |prop_name, prop_value|
      entity[prop_name] = prop_value
    end

    entity
  end

  def entity(table)
    @entities[table]
  end

  def implicit_value(name)
    case name
    when 'phone number'
      message[:from].without_protocol
    end
  end

  def piece_value(guid)
    index = @pieces.index { |piece| piece.guid == guid }
    match[index + 1]
  end

  def insert(table, properties)
    index = application.tire_index
    index.store type: table, properties: properties
    index.refresh
  end

  def update(table, id, properties)
    index = application.tire_index
    index.store type: table, id: id, properties: properties
    index.refresh
  end

  def finish
    @entities.values.each(&:save)
  end
end
