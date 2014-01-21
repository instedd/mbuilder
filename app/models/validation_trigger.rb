class ValidationTrigger < Trigger
  attr_accessible :application_id, :field_guid, :invalid_value, :from, :actions

  belongs_to :application

  validates_presence_of :application, :field_guid, :invalid_value, :from

  serialize :actions

  generate_equals :field_guid, :invalid_value, :from, :actions

  def self.from_hash(hash)
    new field_guid: hash["field_guid"], invalid_value: hash["invalid_value"], actions: Action.from_list(hash["actions"]), from: hash["from"]
  end

  def as_json
    {
      field_guid: field_guid,
      invalid_value: invalid_value,
      kind: kind,
      actions: actions.map(&:as_json),
      from: from
    }
  end

  def table
    application.table_of field_guid
  end

  def field
    table = table()
    table ? table.find_field(field_guid) : nil
  end

  def table_name
    table = table()
    table ? table.name : "???"
  end

  def field_name
    field = field()
    field ? field.name : "???"
  end

  def default_invalid_value_label
    "invalid value"
  end

  def default_from_number
    "+1-(234)-567-8912"
  end
end
