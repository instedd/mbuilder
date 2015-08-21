class ExecutionLogger < ActiveRecord::Base
  belongs_to :application
  belongs_to :trigger, polymorphic: true
  attr_accessible :actions, :message_to, :message_from, :message_body, :application, :trigger, :no_trigger, :with_errors, :trigger_name

  serialize :actions

  scope :no_triggers, -> { where(no_trigger: true) }
  scope :with_errors, -> { where(with_errors: true) }

  before_save do
    self.trigger_name = self.trigger.try &:name
  end

  def message=(message)
    self.message_to = message['to']
    self.message_from = message['from']
    self.message_body = message['body']
  end

  def message
    if self.message_body
      {'to' => message_to, 'from' => message_from, 'body' => message_body}
    else
      nil
    end
  end

  def append_action(*entry)
    self.actions ||= []
    actions << entry
    self
  end

  def insert_values(table_guid, properties)
    append_action :insert, table_guid, properties
  end

  def update_values(table_guid, id, old_properties, new_properties)
    append_action :update, table_guid, id, old_properties, new_properties
  end

  def invalid_value(table_guid, field_guid, value)
    append_action :invalid_value, table_guid, field_guid, value
  end

  def hub_invoke(path, params)
    append_action :hub_invoke, path, params
  end

  def external_service_invoke(service_guid, params)
    append_action :external_service_invoke, service_guid, params
  end

  def info(description)
    append_action :info, description
  end

  def error(description)
    append_action :error, description
    self.with_errors = true
  end

  def error_no_trigger
    self.error "No trigger matched the message."
    self.no_trigger = true
  end

  def warning(description)
    append_action :warning, description
  end

  def send_message(to, body)
    append_action :send_message, to, body
  end

  def find_table(guid)
    application.find_table(guid) rescue nil
  end

  def find_external_service(guid)
    step = application.find_external_service_step(guid)

  end

  def map_properties(table, properties)
    Hash[properties.map do |key, value|
      field_name = table.find_field(key).name rescue '???'
      [field_name, value.user_friendly]
    end]
  end

  def actions_as_strings
    (actions || []).map do |action|
      text = case action[0]
      when :insert
        kind, table_guid, properties = action
        table = find_table(table_guid)
        named_properties = map_properties(table, properties)
        "Create #{table.name rescue '???'} with: #{named_properties}"
      when :hub_invoke
        kind, path, params = action
        "Invoke hub action #{path} with #{params.user_friendly}"
      when :external_service_invoke
        kind, service_guid, params = action
        service_step = find_external_service(service_guid)
        service_name = "#{service_step.external_service.name} :: #{service_step.name}" rescue '???'
        "Invoke external service #{service_name} with #{params.user_friendly}"
      when :update
        kind, table_guid, id, old_properties, new_properties = action
        table = find_table(table_guid)
        old_named_properties = map_properties(table, old_properties)
        new_named_properties = map_properties(table, new_properties)
        "Update #{table.name rescue '???'} where #{old_named_properties} with #{new_named_properties}"
      when :invalid_value
        kind, table_guid, field_guid, value = action
        table = find_table(table_guid)
        field = table.find_field(field_guid) rescue nil
        "Tried to insert invalid value '#{value}' into #{table.name rescue '???'} #{field.name rescue '???'}"
      when :info, :error, :warning
        severity, description = action
        "#{severity.to_s.titleize}: #{description}"
      when :send_message
        kind, to, body = action
        "Send message to #{to}: #{body}"
      end

      {kind: action[0], text: text}
    end
  end
end
