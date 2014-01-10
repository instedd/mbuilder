class TriggerHelper
  attr_reader :actions

  def initialize(application)
    @application = application
    @actions = []
  end

  def message(text, options = {})
    pieces = []
    parse_message(text) do |kind, text|
      if kind == 'text'
        pieces.push 'kind' => 'text', 'text' => text
      else
        pieces.push 'kind' => 'placeholder', 'text' => text, 'guid' => "placeholder_#{text.downcase}"
      end
    end
    @message = Message.from_hash({'pieces' => pieces, 'from' => options[:from]})
  end

  def group_by text
    if text =~ /(\w+)\.(\w+)/
      table = $1
      field = $2
      @actions << Action.from_hash({'kind' => 'group_by', 'table' => "#{table}", 'field' => "#{field}"})
    else
      raise "Wrong action text: #{text}"
    end
  end

  def rule rule, options={}
    @schedule = IceCube::Schedule.new(options[:at])
    @schedule.add_recurrence_rule rule
  end

  def create_entity(text)
    new_entity_action 'create_entity', text
  end

  def select_entity(text)
    new_entity_action 'select_entity', text
  end

  def store_entity_value(text)
    new_entity_action 'store_entity_value', text
  end

  def new_entity_action(kind, text)
    if text =~ /(\w+)\.(\w+) = (.+)/
      table = $1
      field = $2
      pill = pill($3)
      @actions << Action.from_hash({'kind' => kind, 'table' => "#{table}", 'field' => "#{field}", 'pill' => pill})
    else
      raise "Wrong action text: #{text}"
    end
  end

  def send_message(recipient, text)
    case recipient
    when /'(.+)'/
      recipient = {'kind' => 'text', 'guid' => $1}
    when /\*(.+)/
      recipient = {'kind' => 'field_value', 'guid' => $1}
    when /\{(phone_number|invalid_value)\}/
      recipient = {'kind' => 'placeholder', 'guid' => $1}
    else
      raise "Unknown recipient: #{recipient}"
    end

    bindings = []
    parse_message(text) do |kind, msg_text|
      if kind == 'text'
        bindings.push 'kind' => 'text', 'guid' => msg_text
      else
        bindings.push pill(msg_text)
      end
    end

    @actions << Actions::SendMessage.from_hash('message' => bindings, 'recipient' => recipient)
  end

  def foreach(table, &block)
    helper = TriggerHelper.new(@application)
    helper.instance_eval &block
    @actions << Actions::Foreach.new(table, helper.actions)
  end

  def trigger
    trigger = @application.message_triggers.make_unsaved
    trigger.message = @message
    trigger.actions = @actions
    trigger.save!

    trigger
  end

  def periodic_task
    periodic_task = @application.periodic_tasks.make_unsaved
    periodic_task.schedule = @schedule
    periodic_task.actions = @actions
    periodic_task.save!

    periodic_task
  end

  def validation_trigger(field_guid)
    validation_trigger = @application.validation_triggers.make_unsaved field_guid: field_guid
    validation_trigger.from = 'from'
    validation_trigger.invalid_value = 'invalid_value'
    validation_trigger.actions = @actions
    validation_trigger.save!

    validation_trigger
  end
end
