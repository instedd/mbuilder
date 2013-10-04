class ExecutionContext
  attr_reader :application
  attr_reader :messages
  attr_reader :logger

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
    self
  rescue InvalidValueException => ex
    validation_trigger = application.validation_triggers.find_by_field_guid(ex.field_guid)
    if validation_trigger
      context = self.class.new(application, InvalidValuePlaceholderSolver.new(@placeholder_solver, ex.value))
      context.logger.invalid_value(ex.table_guid, ex.field_guid, ex.value)
      context.execute(validation_trigger)
    else
      self
    end
  end

  def new_entity(table)
    @entities[table] = NewEntity.new(self, table)
  end

  def select_entities(table, field, value)
    (@entities[table] ||= EntitySelection.new(self, table)).eq(field, value)
  end

  def entity(table)
    @entities[table] ||= EntitySelection.new(self, table)
  end

  def group_by(table, field)
    (@entities[table] ||= EntitySelection.new(self, table)).group_by = field
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
    @messages.push({from: "app://mbuilder", to: to.with_protocol("sms"), body: body})
  end

  def check_valid_value!(table_guid, field_guid, value)
    table = application.find_table(table_guid)
    field = table.find_field(field_guid)

    unless field.valid_value?(value)
      raise InvalidValueException.new(table_guid, field_guid, value)
    end
  end

  def save
    @entities.values.each(&:save)
    @entities = {}
  end

  def apply_aggregation aggregate, value
    return value unless aggregate.present?

    values = Array(value)

    case aggregate
    when 'count'
      values.length
    when 'total'
      values.sum(&:to_f).user_friendly
    when 'mean'
      sum = values.sum(&:to_f)
      len = values.length
      (len == 0 ? 0 : sum / len).user_friendly
    when 'max'
      values.map(&:to_f).max.user_friendly
    when 'min'
      values.map(&:to_f).min.user_friendly
    else
      raise "Unknown aggregate function: #{aggregate}"
    end
  end
end
