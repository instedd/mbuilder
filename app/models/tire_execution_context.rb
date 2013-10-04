class TireExecutionContext < ExecutionContext

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

  def select_table_field(table, restrictions, field, group_by, aggregate)
    if group_by.present?
      results = perform_search(table, restrictions) do |search|
        if group_by ==  field
          search.facet ("#{group_by}_facet") do
            terms group_by
          end
        else
          search.facet ("#{group_by}_facet") do
            terms_stats group_by, field
          end
        end
      end
      if aggregate.present?
        results.facets["#{group_by}_facet"]['terms'].map { |result| result[aggregate].user_friendly }
      else
        results.facets["#{group_by}_facet"]['terms'].map { |result| result['term'].user_friendly }
      end
    else
      results = perform_search(table, restrictions)

      value = results.map do |result|
        result["_source"]["properties"][field].user_friendly
      end
      apply_aggregation aggregate, value
    end
  end

  def perform_search(table, restrictions)
    search = application.tire_search(table)

    apply_restrictions_to search, restrictions

    yield search if block_given?

    search.perform.results
  end

  def apply_restrictions_to(search, restrictions)
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
  end
end
