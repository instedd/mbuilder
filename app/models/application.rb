class Application < ActiveRecord::Base
  attr_accessible :name, :user_id

  validates_presence_of :name

  belongs_to :user
end
