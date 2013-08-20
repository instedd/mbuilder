class Application < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :triggers

  validates_presence_of :user
  validates_presence_of :name
end
