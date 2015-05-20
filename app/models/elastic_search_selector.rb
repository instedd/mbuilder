class ElasticSearchSelector
  subclass_responsibility :value

  def self.for(restrictions, field, group_by, aggregate)
    SuitableClassFinder.find_leaf_subclass_of(self,
      suitable_for: [field, group_by, aggregate]).new(restrictions, field, group_by, aggregate)
  end

  def perform_search(search, restrictions)
    query = TireHelper.build_query(restrictions)

    body = {}
    body[:query] = query if query

    raise 'not supported' if block_given?

    results = search.client.search(search.options.merge({ body: body }))
    # TODO pagination
    results['hits']['hits']
  end

  def perform_search_raw(search, restrictions)
    query = TireHelper.build_query(restrictions)

    body = {}
    body[:query] = query if query

    yield body if block_given?

    results = search.client.search(search.options.merge({ body: body }))

    # TODO pagination?

    results
  end
end
