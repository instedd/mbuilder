class LocalIndex
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def client
    Elasticsearch::Client.new log: false
  end

  def exists?
    client.indices.exists index: name
  end

  def create(options)
    client.indices.create index: name, body: options
  end

  def delete
    client.indices.delete index: name
  end

  def refresh
    client.indices.refresh index: name
  end
end
