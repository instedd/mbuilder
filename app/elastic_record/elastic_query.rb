class ElasticQuery
  DefaultPageSize = 10

  attr_reader :record
  delegate :client, :index, :type, to: :record
  include Enumerable

  def initialize(record, where_options = {}, order = [], page = nil, page_size = DefaultPageSize)
    @record = record
    @where_options = where_options
    @order = order
    @page = page
    @page_size = page_size
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

    unless @page.nil?
      body[:from] = (@page - 1) * @page_size
    end
    body[:size] = @page_size

    unless @order.empty?
      body[:sort] = @order.map do |sort|
        sort.map do |field, direction|
          {field.to_s => direction.to_s}
        end
      end.flatten
    end

    results = client.search index: index, type: type, body: body

    total = results["hits"]["total"]
    @total_pages = total / @page_size

    results["hits"]["hits"].each do |result|
      yield result["_source"]["properties"].with_indifferent_access
    end

    if @page.nil?
      current_page = self.next_page
      while current_page.page <= @total_pages
        current_page.each do |s|
          yield s
        end
        current_page = current_page.next_page
      end
    end

    self
  end

  def empty?
    count == 0
  end

  def clone
    ElasticQuery.new(@record, @where_options.clone, @order.clone, @page, @page_size)
  end

  def page(page = nil)
    if page.nil?
      @page
    else
      clone.page!(page)
    end
  end

  def page!(page)
    @page = page.to_i
    self
  end

  def per(page_size)
    clone.per!(page_size)
  end

  def per!(page_size)
    @page_size = page_size || DefaultPageSize
    self
  end

  def current_page
    @page
  end

  def total_pages
    @total_pages
  end

  def limit_value
    @page_size
  end

  def next_page
    page((@page || 1) + 1)
  end
end
