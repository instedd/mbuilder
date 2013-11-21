class ElasticRecord
  attr_reader :index, :type, :client

  # (Elasticsearch::Client.new log: true).search index: index_name, type: table, body: yield

  def initialize(index, type)
    @index = index
    @type = type
    @client = Elasticsearch::Client.new log: false
  end

  def where(options)
    all.where!(options)
  end

  def all
    ElasticQuery.new(self)
  end
end
