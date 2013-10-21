class DatabaseExecutionContext < ExecutionContext
  def initialize(application, placeholder_solver)
    super
    @index = application.tire_index
  end

  def self.execute(application, trigger, placeholder_solver)
    context = new application, placeholder_solver
    context.execute trigger
  end

  def piece_value(guid)
    @placeholder_solver.piece_value(guid, @trigger)
  end

  def insert(table, properties)
    application.find_table(table).insert_in(self, properties)
  end

  def insert_local(table, properties)
    now = Tire.format_date(Time.now)

    @index.store type: table, properties: properties, created_at: now, updated_at: now
    @index.refresh

    @logger.insert(table, properties)
  end

  def insert_in_resource_map(table, properties)
    collection = resource_map_api.collections.find(table)

    values = {"properties" => {}}
    properties.each do |field, value|
      if reserved?(field)
        values[field] = value.user_friendly
      else
        values["properties"][field] = value.user_friendly
      end
    end

    collection.sites.create values
  end

  def update_many(table, restrictions, properties)
    results = TireHelper.perform_search(application.tire_search(table), restrictions)

    now = Tire.format_date(Time.now)

    results.each do |result|
      old_properties = result["_source"]["properties"]
      new_properties = old_properties.merge(properties)

      @index.store type: table, id: result["_id"], properties: new_properties, updated_at: now

      @logger.update(table, result["_id"], old_properties, new_properties)
    end

    @index.refresh
  end

  def select_table_field(table, restrictions, field, group_by, aggregate)
    application.find_table(table).select_field_in(self, restrictions, field, group_by, aggregate)
  end

  def select_local_field(table, restrictions, field, group_by, aggregate)
    ElasticSearchSelector.for(restrictions, field, group_by, aggregate).select(application.tire_search table)
  end

  def select_resource_map_field(table, restrictions, field, group_by, aggregate)
    collection = resource_map_api.collections.find(table)
    field_code = field_code_of field.id, collection

    query = restrictions.each_with_object({}) do |restriction, hash|
      hash[field_code_of restriction[:field], collection] = restriction[:value].user_friendly
    end
    sites = collection.sites.where(query)

    if multiple_options? field.kind
      mapping = collection.field_by_id(field.id)
    end

    sites.map do |site|
      if reserved? field.id
        site.data[field_code]
      else
        if mapping
          mapping.options.find{ |o| o['code'] == site.data["properties"][field_code]}[field.value]
        else
          site.data["properties"][field_code]
        end
      end
    end
  end

  def reserved? field
    ['name', 'lat', 'lng'].include? field
  end

  def multiple_options? field
    ['hierarchy', 'select_one', 'select_many'].include? field
  end

  def field_code_of field, collection
    if reserved? field
      field
    else
      collection.field_by_id(field).code
    end
  end

  def resource_map_api
    @resource_map_api ||= ResourceMap::Api.trusted(application.user.email, ResourceMap::Config.url, ResourceMap::Config.use_https)
  end
end
