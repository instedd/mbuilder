class ExecutionContext
  attr_reader :application
  attr_reader :messages
  attr_reader :logger

  def initialize(application)
    @application = application
    @entities = {}
    @messages = []
    @logger = ExecutionLogger.new(@application)
  end

  def execute(trigger)
    @trigger.execute self
    save
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
    subclass_responsibility
  end

  def entity_field_values(field)
    entity = entity(application.table_of(field).guid)
    entity.field_values(field)
  end

  def insert(table, properties)
    subclass_responsibility
  end

  def update_many(table, restrictions, properties)
    subclass_responsibility
  end

  def send_message(to, body)
    @messages.push({from: "app://mbuilder", to: to.with_protocol("sms"), body: body})
  end

  def save
    @entities.values.each(&:save)
  end
end
