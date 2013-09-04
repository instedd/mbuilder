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
    @index = application.tire_index
  end

  def new_entity(table)
    @entities[table] = NewEntity.new(self, table)
  end

  def select_entities(table, field, value)
    @entities[table] = EntitySelection.new(self, table).eq(field, value)
  end

  def entity(table)
    @entities[table] ||= EntitySelection.new(self, table)
  end

  def implicit_value(name)
    case name
    when 'phone number'
      message['from'].without_protocol
    end
  end

  def piece_value(guid)
    index = @pieces.index { |piece| piece.guid == guid }
    match[index + 1]
  end

  def entity_field_values(table, field)
    entity = entity(table)
    entity.field_values(field)
  end

  def insert(table, properties)
    now = Tire.format_date(Time.now)

    @index.store type: table, properties: properties, created_at: now, updated_at: now
    @index.refresh
  end

  def update_many(table, properties, &block)
    results = perform_search(table, &block)

    now = Tire.format_date(Time.now)

    results.each do |result|
      new_properties = result["_source"]["properties"].merge(properties)
      @index.store type: table, id: result["_id"], properties: new_properties, updated_at: now
    end

    @index.refresh
  end

  def select_table_field(table, field, &block)
    results = perform_search(table, &block)
    results.map do |result|
      result["_source"]["properties"][field]
    end
  end

  def perform_search(table, &block)
    search = application.tire_search(table)

    block.call search

    search.perform.results
  end

  def send_message(to, body)
    @messages.push({from: "app://mbuilder", to: to.with_protocol("sms"), body: body})
  end

  def finish
    @entities.values.each(&:save)
  end
end
