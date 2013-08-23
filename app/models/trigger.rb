class Trigger < ActiveRecord::Base
  attr_accessible :name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name

  serialize :logic

  before_save :compile_message, if: :logic
  def compile_message
    self.pattern = logic.message.compile
  end
end
