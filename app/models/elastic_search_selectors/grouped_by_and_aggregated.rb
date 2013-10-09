class ElasticSearchSelectors::GroupedByAndAggregated < ElasticSearchSelector
  def initialize (restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    group_by = @group_by
    field = @field
    results = perform_search(search, @restrictions) do |search|
        search.facet ("#{group_by}_facet") do
          terms_stats group_by, field
        end
      end
    results.facets["#{group_by}_facet"]['terms'].sort_by { |a| a['term'] }.map do |result|
      result[@aggregate].user_friendly
    end
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.present? && group_by.present?
  end
end