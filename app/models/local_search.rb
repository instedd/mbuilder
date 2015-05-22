class LocalSearch
  def initialize(index, type)
    @index = index
    @type = type
  end

  def client
    Elasticsearch::Client.new log: false
  end

  def options
    {
      index: @index,
      type: @type
    }
  end

  def entities(restrictions = {})
    ElasticSearchSelector.new.perform_search(self, restrictions)
  end
end
