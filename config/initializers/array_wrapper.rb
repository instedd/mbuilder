class ArrayWrapper
  def initialize(value)
    @value = value.sort
  end

  def user_friendly
    self.class.new(@value.user_friendly)
  end

  def to_s
    @value.to_s
  end
end