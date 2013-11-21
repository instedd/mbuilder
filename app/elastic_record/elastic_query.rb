class ElasticQuery
  attr_reader :record
  delegate :client, :index, :type, to: :record
  include Enumerable

  def initialize(record)
    @record = record
    @where_options = {}
  end

  def where(options)
    ElasticQuery.where(self, @where_options.merge(options))
  end

  def self.where(record, options)
    ElasticQuery.new(record).tap do |query|
      query.instance_eval do |query|
        @where_options.merge!(options)
      end
    end
  end

  def self.all(record)
    ElasticQuery.new(record)
  end

  def each
    query = case @where_options.keys.size
    when 0
      { match_all: {} }
    when 1
      k, v = @where_options.first
      { match: {k.to_s => {query: v}}}
    else
      { bool: {must: (@where_options.map { |k, v| {term: {k.to_s => v}} }) } }
    end

    results = client.search index: index, type: type, body: {query: query}

    results["hits"]["hits"].each do |result|
      yield result["_source"]["properties"].with_indifferent_access
    end
  end
end
