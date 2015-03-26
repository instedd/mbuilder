class MessageTrigger < Trigger
  attr_accessible :name, :message, :actions

  belongs_to :application

  validates_presence_of :application, :name

  serialize :message
  serialize :actions

  generate_equals :name, :message, :actions

  scope :enabled, -> { where(enabled: true) }

  def self.from_hash(hash)
    new name: hash["name"], enabled: hash["enabled"], message: Message.from_hash(hash["message"]), actions: Action.from_list(hash["actions"])
  end

  def as_json
    {
      name: name,
      enabled: enabled,
      message: message,
      kind: kind,
      actions: actions.map(&:as_json)
    }
  end

  def default_from_number
    "+1-(234)-567-8912"
  end

  def match incoming_message
    message.match incoming_message
  end
end
