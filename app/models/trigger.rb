class Trigger < ActiveRecord::Base
  attr_accessible :name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name

  serialize :logic

  def as_json(options = {})
    {
      id: id,
      name: name,
      message: logic.message,
      application_id: application_id,
    }
  end
end
