class ElasticSearchSelectors::Grouped < ElasticSearchSelector
  def initialize (restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    group_by = @group_by

    results = search.raw_query @restrictions, {
      aggregations: {
        "#{group_by}_aggregation" => {
          terms: {
            field: ElasticQuery.field_name(group_by)
          }
        }
      }
    }

    results['aggregations']["#{group_by}_aggregation"]["buckets"].sort_by { |a| a['key'] }.map do |result|
      result['key'].user_friendly
    end
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.blank? && group_by.present? && group_by == field
  end
end
