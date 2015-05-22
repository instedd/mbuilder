class ElasticSearchSelectors::Aggregated < ElasticSearchSelector
  def initialize (restrictions, field, group_by, aggregate)
    @restrictions = restrictions
    @field = field
    @group_by = group_by
    @aggregate = aggregate
  end

  def select(search)
    value = search.all_entities(@restrictions).map do |result|
      result[@field].user_friendly
    end
    Aggregator.new(@aggregate).apply_to value
  end

  def self.can_handle? field, group_by, aggregate
    aggregate.present? && group_by.blank?
  end
end
