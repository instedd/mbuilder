class ElasticSearchSelectors::Values < ElasticSearchSelector
  def initialize(restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    results = perform_search(search, @restrictions)
    value = results.map do |result|
      result["_source"]["properties"][@field].user_friendly
    end
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.blank? && group_by.blank?
  end
end