class ElasticRecord

  class << self
    attr_accessor :index, :type, :client
  end

  attr_accessor :id, :properties

  def self.for(index, type)
    table = Class.new(self)
    table.index = index
    table.type = type
    table.client = Elasticsearch::Client.new log: false
    table
  end

  def self.where(options)
    all.where!(options)
  end

  def self.all
    ElasticQuery.new(self)
  end

  def self.columns
    result = client.indices.get_mapping(index: index, type: type)

    result[type]['properties']['properties']['properties'].keys
  end

  def self.human_attribute_name(name)
    name
  end
end
