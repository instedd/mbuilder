class ElasticSearchSelector
  subclass_responsibility :value

  def self.for(restrictions, field, group_by, aggregate)
    SuitableClassFinder.find_leaf_subclass_of(self,
      suitable_for: [field, group_by, aggregate]).new(restrictions, field, group_by, aggregate)
  end

end
