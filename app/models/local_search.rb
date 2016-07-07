class LocalSearch
  def initialize(local_index, type)
    @local_index = local_index
    @type = type
  end

  def client
    @local_index.client
  end

  def options
    {
      index: @local_index.name,
      type: @type
    }
  end

  def create(attributes)
    now = change_timestamp
    client.create options.merge body: {
      properties: attributes,
      created_at: now,
      updated_at: now
    }
  end

  def update(id, attributes)
    client.update options.merge id: id, body: {
      doc: {
        properties: attributes,
        updated_at: change_timestamp
      }
    }
  end

  def all_entities(restrictions = {})
    res = []
    paged_query(restrictions) do |doc|
      res << doc["_source"]["properties"]
    end
    res
  end

  def paged_query(restrictions = {})
    from = 0
    page_size = 10
    yielded_count = 0

    loop do
      results = raw_query(restrictions, { from: from, size: page_size })
      hits = results['hits']['hits']

      yielded_count = yielded_count + hits.length

      hits.each do |doc|
        yield doc
      end

      break if yielded_count == results['total'] || hits.length == 0

      from = from + page_size
    end
  end

  # restrictions is an array of {op, field, value} hash
  # those are translated to a elasticsearch bool query and merged with es_search_options
  def raw_query(restrictions = {}, es_search_options = {})
    query = build_query(restrictions)

    body = {}
    body[:query] = query if query
    body.merge! es_search_options

    results = client.search(self.options.merge({ body: body }))

    results
  end

  private

  def change_timestamp
    Time.now.utc.iso8601
  end

  def build_query(restrictions)
    return unless restrictions.present?

    musts = []
    query = { bool: { must: musts } }

    restrictions.each do |restriction|
      case restriction[:op]
      when :eq
        values = Array(restriction[:value]).map &:to_s

        if values.count == 1
          musts << { match: { ElasticQuery.field_name(restriction[:field]) => values.first } }
        else
          shoulds = []
          match_any_value = { bool: { should: shoulds, minimum_should_match: 1 } }
          musts << match_any_value
          values.each do |v|
            shoulds << { match: { ElasticQuery.field_name(restriction[:field]) => v } }
          end
        end
      end
    end

    query
  end
end
