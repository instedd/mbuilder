class ExecutionContext
  attr_reader :application
  attr_reader :messages
  attr_reader :logger
  attr_accessor :placeholder_solver

  def initialize(application, placeholder_solver)
    @application = application
    @placeholder_solver = placeholder_solver
    @entities = {}
    @messages = []
    @logger = ExecutionLogger.new(@application)
  end

  def execute(trigger)
    @trigger = trigger
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

  def check_valid_value!(table_guid, field_guid, value)
    table = application.find_table(table_guid)
    field = table.find_field(field_guid)

    unless field.valid_value?(value)
      @logger.invalid_value(table_guid, field_guid, value)
      raise InvalidValueException.new(field_guid, value)
    end
  end

  def save
    @entities.values.each(&:save)
    @entities = {}
  end
end
