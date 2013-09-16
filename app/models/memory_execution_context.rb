class MemoryExecutionContext < ExecutionContext
  attr_reader :db

  def initialize(application)
    super
    @db = Hash.new { |hash, table_name| hash[table_name] = [] }
    @next_id = 0
  end

  def execute(trigger)
    @trigger = trigger
    super
  end

  def piece_value(guid)
    case guid
    when 'phone_number'
      @trigger.logic.message.from
    else
      @trigger.logic.message.pieces.find { |piece| piece.guid == guid }.text
    end
  end

  def insert(table, properties)
    @db[table] << properties.merge({ 'id' => next_id })
    @logger.insert(table, properties)
  end

  def update_many(table, restrictions, properties)
    rows = @db[table]

    matcher = restrictions.inject(lambda { |item| true }) do |matcher, restriction|
      case restriction[:op]
      when :eq
        values = Array(restriction[:value])
        lambda { |item| values.include?(item[restriction[:field]]) && matcher.call(item) }
      end
    end

    result_rows = rows.select &matcher
    result_rows.each do |row|
      row.merge!(properties)
      @logger.update(table, properties['id'], row, properties)
    end
  end

  def data_for(table)
    @db[table].collect do |row|
      row.except 'id'
    end
  end

  def next_id
    @next_id += 1
  end
end
