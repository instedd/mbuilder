class ExecutionContext
  attr_reader :application
  attr_reader :trigger
  attr_reader :message
  attr_reader :match
  attr_reader :messages
  attr_reader :logger

  def initialize(application, trigger, message, match)
    @application = application
    @trigger = trigger
    @message = message
    @match = match
    @entities = {}
    @pieces = @trigger.logic.message.pieces.select { |piece| piece.kind == 'placeholder' }
    @messages = []
    @logger = ExecutionLogger.new(@application)
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

  def piece_value(guid)
    case guid
    when 'phone number'
      message['from'].without_protocol
    else
      index = @pieces.index { |piece| piece.guid == guid }
      match[index + 1]
    end
  end

  def entity_field_values(table, field)
    entity = entity(table)
    entity.field_values(field)
  end

  def insert(table, properties)
    now = Tire.format_date(Time.now)

    @index.store type: table, properties: properties, created_at: now, updated_at: now
    @index.refresh

    @logger.insert(table, properties)
  end

  def update_many(table, properties, &block)
    results = perform_search(table, &block)

    now = Tire.format_date(Time.now)

    results.each do |result|
      old_properties = result["_source"]["properties"]
      new_properties = old_properties.merge(properties)

      @index.store type: table, id: result["_id"], properties: new_properties, updated_at: now

      @logger.update(table, result["_id"], old_properties, new_properties)
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

  def save
    @entities.values.each(&:save)
  end
end
