class Actions::ExternalService < Action
  attr_accessor :guid, :pills, :results

  def initialize(guid, pills, results)
    @guid = guid
    @pills = pills
    @results = results
  end

  generate_equals :guid, :pills, :results

  def execute(context)
    response = context.external_service_invoke(guid, pills.value_in(context))

    @results.each do |result_pill|
      context.assign_result_value result_pill.guid, response[result_pill.name]
    end
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
