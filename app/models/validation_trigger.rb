class ValidationTrigger < ActiveRecord::Base
  attr_accessible :application_id, :field_guid, :logic

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :field_guid

  serialize :logic

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

  def generate_invalid_value
    "invalid value"
  end

  def generate_from_number
    "+1-(234)-567-8912"
  end
end
