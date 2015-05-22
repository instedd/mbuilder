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
    client.create options.merge body: attributes
  end

  def update(id, attributes)
    client.update options.merge id: id, body: { doc: attributes }
  end
end
