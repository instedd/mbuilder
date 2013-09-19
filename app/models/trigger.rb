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
    logic.actions.each do |action|
      action.execute(context)
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
