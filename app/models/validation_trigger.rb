class ValidationTrigger < Trigger
  attr_accessible :application_id, :field_guid, :invalid_value, :from, :actions

  belongs_to :application

  validates_presence_of :application, :field_guid, :invalid_value, :from

  serialize :actions

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

  def generate_invalid_value # TODO default_invalid_value_label
    "invalid value"
  end

  def generate_from_number # TODO default_from_number
    "+1-(234)-567-8912"
  end
end
