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
    aggregate = @aggregate

    results = perform_search_raw(search, @restrictions) do |search|
      search[:aggregations] = {
        "#{group_by}_aggregation" => {
          terms: {
            field: group_by,
          },
          aggregations: {
            "#{field}_#{aggregate}" => {
              es_aggregation(aggregate) => {
                field: field
              }
            }
          }
        }
      }
    end

    results["aggregations"]["#{group_by}_aggregation"]['buckets'].sort_by { |a| a['key'] }.map do |result|
      result["#{field}_#{aggregate}"]["value"].user_friendly
    end
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.present? && group_by.present?
  end

  def es_aggregation(aggregate)
    case aggregate
    when 'count'
      'value_count'
    when 'total'
      'sum'
    when 'mean'
      'avg'
    when 'max'
      'max'
    when 'min'
      'min'
    else
      raise "Unknown aggregate function: #{aggregate}"
    end
  end
end
