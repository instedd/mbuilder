class ElasticQuery
  DefaultPageSize = 10

  attr_reader :record
  delegate :client, :index, :type, :human_attribute_name, to: :record
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
    results["hits"]["hits"].each do |result|
      new_record = @record.new
      new_record.id = result["_id"]
      new_record.properties = result["_source"]["properties"].with_indifferent_access
      # result["_source"]["properties"]["id"]= result["_id"]
      # yield result["_source"]["properties"].with_indifferent_access
      yield new_record
    end

    if @page.nil?
      current = self.next_page
      while current.current_page <= total_pages
        current.each do |s|
          yield s
        end
        current = current.next_page
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

  def current_page
    @page
  end

  def page(page)
    clone.page!(page)
  end

  def page!(page)
    @page = page.to_i
    self
  end

  def next_page
    page((@page || 1) + 1)
  end

  def per(page_size)
    clone.per!(page_size)
  end

  def per!(page_size)
    @page_size = page_size || DefaultPageSize
    self
  end

  def limit_value
    @page_size
  end

  def total_pages
    @total_pages ||= (results["hits"]["total"].fdiv @page_size).ceil
  end

  def results
    @results ||= begin
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

      client.search index: index, type: type, body: body
    end
  end
end
