class ElasticSearchSelector
  subclass_responsibility :value

  def self.for(restrictions, field, group_by, aggregate)
    SuitableClassFinder.find_leaf_subclass_of(self,
      suitable_for: [field, group_by, aggregate]).new(restrictions, field, group_by, aggregate)
  end

  def perform_search(search, restrictions)
    items = []
    query = build_query(restrictions)

    body = {}
    body[:query] = query if query

    raise 'not supported' if block_given?

    from = 0
    page_size = 10

    # TODO would be better to yield results, but yielding was used to override search options

    loop do
      search_options = search.options.merge({from: from, size: page_size, body: body })
      results = search.client.search(search_options)
      items.concat(results['hits']['hits'])

      break if items.length == results['total'] || results['hits']['hits'].length == 0

      from = from + page_size
    end

    items
  end

  def perform_search_raw(search, restrictions)
    query = build_query(restrictions)

    body = {}
    body[:query] = query if query

    yield body if block_given?

    results = search.client.search(search.options.merge({ body: body }))

    # aggregated results do not need to be paginated

    results
  end

  private

  def build_query(restrictions)
    return unless restrictions.present?

    musts = []
    query = { bool: { must: musts } }

    restrictions.each do |restriction|
      case restriction[:op]
      when :eq
        values = Array(restriction[:value]).map &:to_s

        if values.count == 1
          musts << { match: { restriction[:field] => values.first } }
        else
          shoulds = []
          match_any_value = { bool: { should: shoulds, minimum_should_match: 1 } }
          musts << match_any_value
          values.each do |v|
            shoulds << { match: { restriction[:field] => v } }
          end
        end
      end
    end

    query
  end
end
