class Logic
  attr_accessor :incoming_message

  def initialize(data = {})
    @incoming_message = data['incoming_message']
  end

  def as_json(options = {})
    {
      incoming_message: incoming_message,
    }
  end
end
