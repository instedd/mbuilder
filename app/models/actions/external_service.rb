class Actions::ExternalService < Action
  attr_accessor :guid, :pills, :results

  def initialize(guid, pills, results)
    @guid = guid
    @pills = pills
    @results = results
  end

  generate_equals :guid, :pills, :results

  def execute(context)
    pills.value_in(context)
    # TODO call external service, fill params using pills, extract response, and save results into context for future consumption
  end

  def as_json
    {
      kind: 'external_service',
      guid: guid,
      pills: pills.as_json,
      results: results.as_json
    }
  end

  def self.from_hash(hash)
    new hash['guid'], pills_from_hash(hash['pills']), results_from_list(hash['results'])
  end

  def self.pills_from_hash(hash)
    hash.inject({}){ |r, (k,v)| r[k] = Pill.from_hash(v); r }
  end

  def self.results_from_list(list)
    list.map{|x| Pills::ResultPill.from_hash(x)}
  end
end
