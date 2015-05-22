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

  def entities(restrictions = {})
    ElasticSearchSelector.new.perform_search(self, restrictions)
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

  private

  def change_timestamp
    Time.now.utc.iso8601
  end
end
