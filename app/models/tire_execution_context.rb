class TireExecutionContext < ExecutionContext

  def initialize(application, trigger, message, match)
    super application
    @trigger = trigger
    @message = message
    @match = match
    @pieces = @trigger.logic.message.pieces.select { |piece| piece.kind == 'placeholder' }
    @index = application.tire_index
  end

  def self.execute(application, trigger, message, match)
    context = new application, trigger, message, match
    context.execute trigger
    context
  end

  def piece_value(guid)
    case guid
    when 'phone_number'
      @message['from'].without_protocol
    else
      index = @pieces.index { |piece| piece.guid == guid }
      @match[index + 1]
    end
  end

  def insert(table, properties)
    now = Tire.format_date(Time.now)

    @index.store type: table, properties: properties, created_at: now, updated_at: now
    @index.refresh

    @logger.insert(table, properties)
  end

  def update_many(table, restrictions, properties)
    results = perform_search(table, restrictions)

    now = Tire.format_date(Time.now)

    results.each do |result|
      old_properties = result["_source"]["properties"]
      new_properties = old_properties.merge(properties)

      @index.store type: table, id: result["_id"], properties: new_properties, updated_at: now

      @logger.update(table, result["_id"], old_properties, new_properties)
    end

    @index.refresh
  end

  def select_table_field(table, restrictions, field)
    results = perform_search(table, restrictions)
    results.map do |result|
      result["_source"]["properties"][field]
    end
  end

  def perform_search(table, restrictions)
    search = application.tire_search(table)

    restrictions.each do |restriction|
      search.query do
        case restriction[:op]
        when :eq
          values = Array(restriction[:value])
          boolean do
            values.each do |value|
              should { match restriction[:field], value }
            end
          end
        end
      end
    end

    search.perform.results
  end
end