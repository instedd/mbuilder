class Actions::Hub < Action
  attr_accessor :path, :selection, :reflect, :pills

  def initialize(path, selection, reflect, pills)
    @path = path
    @selection = selection
    @reflect = reflect
    @pills = pills
  end

  generate_equals :path, :selection, :reflect, :pills

  def execute(context)
    context.hub_action_invoke path, pills.value_in(context).user_friendly
  end

  def as_json
    {
      kind: 'hub',
      path: path,
      selection: selection,
      reflect: reflect,
      pills: pills.as_json
    }
  end

  def self.from_hash(hash)
    new hash['path'], hash['selection'], hash['reflect'], pills_from_hash_of_pills(hash['pills'])
  end

  def self.pills_from_hash_of_pills(hash)
    # pills are saved as hash, within a hash in this case
    # so we need to navigate the hash until the values that has hashes without hashes as values.
    # this works because in the hash the only values we care are pills
    # and the pills only have atomic values
    actual_hash = hash.empty? || hash.values.any? { |e| e.is_a? Hash }
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
