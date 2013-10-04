class MemoryExecutionContext < ExecutionContext

  def initialize(application, placeholder_solver)
    super
    @db = Hash.new { |hash, table_name| hash[table_name] = [] }
    @next_id = 0
  end

  def execute_many triggers
    triggers.each { |trigger| execute trigger }
    @db
  end

  def piece_value(guid)
    @placeholder_solver.piece_value guid, @trigger
  end

  def insert(table, properties)
    @db[table] << properties.merge({ 'id' => next_id })
    @logger.insert(table, properties)
  end

  def update_many(table, restrictions, properties)
    rows = @db[table]

    result_rows = rows.select &(matcher_from restrictions)

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

  def select_table_field(table, restrictions, field, group_by, aggregate)
    rows = @db[table]

    result_rows = rows.select &(matcher_from restrictions)

    if group_by.present?
        grouped_rows = result_rows.group_by do |field|
          field[group_by]
        end
        values = grouped_rows.map do |grouped_field, results_by_field|
          results_by_field.map do|result|
            result[field]
          end
        end
      if group_by == field
        values.map &:first
      else
        values.map do |value|
          apply_aggregation aggregate, value
        end
      end
    else
      value = result_rows.map do |result|
        result[field]
      end
      apply_aggregation aggregate, value
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
