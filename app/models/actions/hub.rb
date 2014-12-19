class Actions::Hub < Action
  attr_accessor :path, :reflect, :pills

  def initialize(path, reflect, pills)
    @path = path
    @reflect = reflect
    @pills = pills
  end

  generate_equals :path, :reflect, :pills

  def execute(context)
    context.hub_action_invoke path, pills.value_in(context)
  end

  def as_json
    {
      kind: 'hub',
      path: path,
      reflect: reflect,
      pills: pills.as_json
    }
  end

  def self.from_hash(hash)
    new hash['path'], hash['reflect'], pills_from_hash_of_pills(hash['pills'])
  end

  def self.pills_from_hash_of_pills(hash)
    actual_hash = hash.values.any? { |e| e.is_a? Hash }
    if actual_hash
      res = {}
      hash.each do |key, value|
        res[key] = pills_from_hash_of_pills(value)
      end
      res
    else
      Pill.from_hash(hash)
    end
  end
end
