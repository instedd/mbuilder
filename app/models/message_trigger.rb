class MessageTrigger < Trigger
  attr_accessible :name, :message, :actions

  belongs_to :application

  validates_presence_of :application, :name

  serialize :message
  serialize :actions

  def generate_from_number # TODO default_from_number
    "+1-(234)-567-8912"
  end

  def match incoming_message
    message.match incoming_message
  end
end
