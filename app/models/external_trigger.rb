class ExternalTrigger < ActiveRecord::Base
  belongs_to :application
  attr_accessible :actions, :name, :parameters
  validates_uniqueness_of :name, scope: :application_id
  serialize :parameters
  serialize :actions

  def route
    ''
  end
end
