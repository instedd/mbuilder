class Actions::Hub < Action
  attr_accessor :path, :reflect, :pills

  def initialize(path, reflect, pills)
    @path = path
    @reflect = reflect
    @pills = pills
  end

  generate_equals :path, :reflect, :pills

  def execute(context)
  end

  def as_json
    {
      kind: 'hub',
      path: path,
      reflect: reflect,
      pills: pills
    }
  end

  def self.from_hash(hash)
    new hash['path'], hash['reflect'], hash['pills']
  end

  # TODO implement rebind_table, rebind_field
end
