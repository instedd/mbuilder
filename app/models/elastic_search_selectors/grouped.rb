class ElasticSearchSelectors::Grouped < ElasticSearchSelector
  def initialize (restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    group_by = @group_by
    results = perform_search_raw(search, @restrictions) do |search|
      search[:aggregations] = {
        "#{group_by}_aggregation" => {
          terms: {
            field: group_by
          }
        }
      }
    end
    results['aggregations']["#{group_by}_aggregation"]["buckets"].sort_by { |a| a['key'] }.map do |result|
      result['key'].user_friendly
    end
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.blank? && group_by.present? && group_by == field
  end
end
