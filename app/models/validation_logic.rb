class ValidationLogic
  attr_accessor :from
  attr_accessor :invalid_value
  attr_accessor :actions

  def initialize(from, invalid_value, actions)
    @from = from
    @invalid_value = invalid_value
    @actions = actions
  end
end
