class Channel < ActiveRecord::Base
  attr_accessible :application_id, :name, :pigeon_name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name
end
