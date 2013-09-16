class MemoryExecutionContext < ExecutionContext
  attr_reader :db

  def initialize(application)
    @application = application
    @entities = {}
    @messages = []
    @db = Hash.new { |hash, table_name| hash[table_name] = [] }
  end

  def execute(trigger)
    @trigger = trigger
    trigger.execute self
    save
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
    @db[table] << properties
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
    end
  end

  def data_for(table)
    @db[table]
  end
end
