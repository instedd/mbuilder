class Trigger < ActiveRecord::Base
  include Rebindable

  attr_accessible :name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name

  serialize :logic

  before_save :compile_message, if: :logic

  def compile_message
    self.pattern = logic.message.compile
  end

  def execute(context)
    logic.execute(context)
  rescue InvalidValueException => ex
    validation_trigger = application.validation_triggers.find_by_field_guid(ex.field_guid)
    if validation_trigger
      context.placeholder_solver = InvalidValuePlaceholderSolver.new(context.placeholder_solver, ex.value)
      context.execute(validation_trigger)
    end
  end

  def generate_from_number
    "+1-(234)-567-8912"
  end

  def rebind_table(from_table, to_table)
    logic.rebind_table(from_table, to_table)
  end

  def rebind_field(from_field, to_table, to_field)
    logic.rebind_field(from_field, to_table, to_field)
  end
end
