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
end
