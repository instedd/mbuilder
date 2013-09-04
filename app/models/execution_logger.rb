class ExecutionLogger
  def initialize(application)
    @application = application
    @actions = []
  end

  def insert(table_guid, properties)
    @actions << [:insert, table_guid, properties]
  end

  def update(table_guid, id, old_properties, new_properties)
    @actions << [:update, table_guid, id, old_properties, new_properties]
  end

  def find_table(guid)
    @application.find_table(guid)
  end

  def map_properties(table, properties)
    Hash[properties.map do |key, value|
      field = table.find_field(key)
      [field.name, value]
    end]
  end

  def actions_as_strings
    @actions.map do |action|
      case action[0]
      when :insert
        kind, table_guid, properties = action
        table = find_table(table_guid)
        named_properties = map_properties(table, properties)
        "Create #{table.name} with: #{named_properties}"
      when :update
        kind, table_guid, id, old_properties, new_properties = action
        table = find_table(table_guid)
        old_named_properties = map_properties(table, old_properties)
        new_named_properties = map_properties(table, new_properties)
        "Update #{table.name} where #{old_named_properties} with #{new_named_properties}"
      end
    end
  end
end
