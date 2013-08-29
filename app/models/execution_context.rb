class ExecutionContext
  attr_reader :application
  attr_reader :trigger
  attr_reader :message
  attr_reader :match
  attr_reader :messages

  def initialize(application, trigger, message, match)
    @application = application
    @trigger = trigger
    @message = message
    @match = match
    @entities = {}
    @pieces = @trigger.logic.message.pieces.select { |piece| piece.kind == 'pill' }
    @messages = []
  end

  def new_entity(table)
    @entities[table] = NewEntity.new(self, table)
  end

  def select_entities(table, field, value)
    @entities[table] = EntitySelection.new(self, table).eq(field, value)
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

  def update_many(table, properties)
    index = application.tire_index
    search = application.tire_search(table)

    yield search

    results = search.perform.results
    results.each do |result|
      new_properties = result["_source"]["properties"].merge(properties)
      index.store type: table, id: result["_id"], properties: new_properties
    end

    index.refresh
  end

  def send_message(to, body)
    @messages.push({from: "app://mbuilder", to: to.with_protocol("sms"), body: body})
  end

  def finish
    @entities.values.each(&:save)
  end
end
