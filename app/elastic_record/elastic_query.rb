class ElasticQuery
  attr_reader :record
  delegate :client, :index, :type, to: :record
  include Enumerable

  def initialize(record, where_options = {}, order = [])
    @record = record
    @where_options = where_options
    @order = order
  end

  def where(options)
    clone.tap do |query|
      query.where! options
    end
  end

  def where!(options)
    @where_options.merge!(options)
    self
  end

  def order(options)
    clone.tap do |query|
      query.order! options
    end
  end

  def reorder(options)
    clone.tap do |query|
      query.reorder! options
    end
  end

  def reorder!(options)
    @order = []
    order! options
  end

  def order!(options)
    @order << options
    self
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

    body = { query: query }

    unless @order.empty?
      body[:sort] = @order.map do |sort|
        sort.map do |field, direction|
          {field.to_s => direction.to_s}
        end
      end.flatten
    end

    results = client.search index: index, type: type, body: body

    results["hits"]["hits"].each do |result|
      yield result["_source"]["properties"].with_indifferent_access
    end
  end

  def clone
    ElasticQuery.new(record, @where_options.clone, @order.clone)
  end


  # def page(page_number)
  #   clone.page!(page_number)
  # end

  # def per(page_size)

  # end

end
