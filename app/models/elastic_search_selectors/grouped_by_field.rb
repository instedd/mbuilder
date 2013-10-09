class ElasticSearchSelectors::GroupedByField < ElasticSearchSelector
  def initialize (restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    perform_search(search, @restrictions).
      map { |result| result["_source"]["properties"] }.
      group_by { |result| result[@group_by] }.
      sort_by { |key, value| key }.
      map { |key, value| ArrayWrapper.new(value.map { |a| a[@field]}) }
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.blank? && group_by.present? && group_by != field
  end
end