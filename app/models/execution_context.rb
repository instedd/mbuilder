class ExecutionContext
  attr_reader :application
  attr_reader :messages
  attr_reader :logger

  def initialize(application, placeholder_solver, logger)
    @application = application
    @placeholder_solver = placeholder_solver
    @entities_stack = [{}]
    @messages = []
    @logger = logger
  end

  def execute(trigger)
    @trigger = trigger
    @trigger.execute self
    save
    self
  rescue InvalidValueException => ex
    validation_trigger = application.validation_triggers.find_by_field_guid(ex.field_guid)
    if validation_trigger
      context = self.class.new(application, InvalidValuePlaceholderSolver.new(@placeholder_solver, ex.value), logger)
      context.logger.invalid_value(ex.table_guid, ex.field_guid, ex.value)
      context.execute(validation_trigger)
    else
      self
    end
  end

  def in_subcontext
    @entities_stack.push({})
    yield
    save
    @entities_stack.pop
  end

  def new_entity(table)
    entities[table] = NewEntity.new(self, table)
  end

  def select_entities(table, field, value)
    entity = entities[table]
    unless entity
      entity = find_entity(table)
      if entity
        entity = entities[table] = entity.clone
      else
        entity = entities[table] = EntitySelection.new(self, table)
      end
    end
    entity.eq(field, value)
    entity
  end

  def entity(table)
    find_or_create_entity(table) { EntitySelection.new(self, table) }
  end

  def set_entity(table, entity)
    entities[table] = entity
  end

  def group_by(table, field)
    find_or_create_entity(table) { EntitySelection.new(self, table) }.group_by = field
  end

  def piece_value(guid)
    subclass_responsibility
  end

  def entity_field_values(field, aggregate)
    entity = entity(application.table_of(field).guid)
    entity.field_values(field, aggregate)
  end

  def insert(table, properties)
    subclass_responsibility
  end

  def update_many(table, restrictions, properties)
    subclass_responsibility
  end

  def send_message(to, body)
    @messages.push({from: "app://mbuilder", to: to.with_protocol("sms"), body: body, :'mbuilder-application' => application.id})
    logger.send_message(to, body)
  end

  def check_valid_value!(table_guid, field_guid, value)
    table = application.find_table(table_guid)
    field = table.find_field(field_guid)

    unless field.valid_value?(value)
      raise InvalidValueException.new(table_guid, field_guid, value)
    end
  end

  def save
    entities.values.each(&:save)
    entities.clear
  end

  private

  def entities
    @entities_stack.last
  end

  def find_or_create_entity(table)
    entity = find_entity(table)
    if entity
      entity
    else
      entities[table] = yield
    end
  end

  def find_entity(table)
    @entities_stack.reverse_each do |entities|
      entity = entities[table]
      return entity if entity
    end
    nil
  end
end
