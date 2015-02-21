class Actions::ExternalService < Action
  attr_accessor :guid, :pills, :parameters

  def initialize(guid, pills, parameters)
    @guid = guid
    @pills = pills
    @parameters = parameters
  end

  generate_equals :guid, :pills, :parameters

  def execute(context)
    pills.value_in(context)
    binding.pry
    # TODO call external service, fill params, extract response
    #context.hub_action_invoke path, pills.value_in(context)
  end

  def as_json
    {
      kind: 'external_service',
      guid: guid,
      pills: pills.as_json,
      parameters: parameters.as_json
    }
  end

  def self.from_hash(hash)
    new hash['guid'], pills_from_hash(hash['pills']), params_from_list(hash['parameters'])
  end

  def self.pills_from_hash(hash)
    hash.inject({}){ |r, (k,v)| r[k] = Pill.from_hash(v); r }
  end

  def self.params_from_list(list)
    list.map{|x| Pills::ParameterPill.from_hash(x)}
  end
end
