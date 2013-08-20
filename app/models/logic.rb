class Logic
  attr_accessor :message

  def initialize(data = {})
    @message = data['message']
  end

  def as_json(options = {})
    {
      message: message,
    }
  end
end
