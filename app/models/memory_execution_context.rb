class MemoryExecutionContext < ExecutionContext
  def initialize(application, placeholder_solver, logger)
    super
    @db = Hash.new { |hash, table_name| hash[table_name] = [] }
    @next_id = 0
  end

  def execute_many triggers
    triggers.each { |trigger| execute trigger rescue nil }
    @db
  end

  def piece_value(guid)
    @placeholder_solver.piece_value guid, @trigger
  end

  def insert(table, properties)
    @db[table] << properties.merge({ 'id' => next_id })
    @logger.insert_values(table, properties)
  end

  def update_many(table, restrictions, properties)
    rows = @db[table]

    result_rows = rows.select &(matcher_from restrictions)

    result_rows.each do |row|
      row.merge!(properties)
      @logger.update_values(table, properties['id'], row, properties)
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

  def each_value(table, restrictions, group_by, &block)
    rows = @db[table]

    result_rows = rows.select &(matcher_from restrictions)

    result_rows.each &block
  end

  def select_table_field(table, restrictions, field, group_by, aggregate)
    rows = @db[table]

    result_rows = rows.select &(matcher_from restrictions)

    if group_by.present?
      grouped_rows = result_rows.group_by do |field|
        field[group_by]
      end
      values = grouped_rows.sort_by { |key, value| key }.map do |grouped_field, results_by_field|
        results_by_field.map do|result|
          result[field]
        end
      end
      if group_by == field
        values.map &:first
      else
        if aggregate
          values.map do |value|
            Aggregator.new(aggregate).apply_to value
          end
        else
          values.map do |group_of_fields|
            ArrayWrapper.new(group_of_fields)
          end
        end
      end
    else
      value = result_rows.map do |result|
        result[field]
      end
      Aggregator.new(aggregate).apply_to value
    end
  end

  def matcher_from restrictions
    restrictions.inject(lambda { |item| true }) do |matcher, restriction|
      case restriction[:op]
      when :eq
        values = Array(restriction[:value])
        lambda { |item| values.include?(item[restriction[:field]]) && matcher.call(item) }
      end
    end
  end
end
