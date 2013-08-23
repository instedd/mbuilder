class Logic
  attr_accessor :message
  attr_accessor :actions

  def initialize(message, actions)
    @message = message
    @actions = actions
  end
end
