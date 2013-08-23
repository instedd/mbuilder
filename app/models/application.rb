class Application < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :triggers
  has_many :channels

  validates_presence_of :user
  validates_presence_of :name

  serialize :tables

  def accept_message(message)
    Executor.new(self).execute(message)
  end

  def tire_index
    index = Tire::Index.new(tire_name)
    index.create unless index.exists?
    index
  end

  def tire_search
    Tire::Search::Search.new(tire_name)
  end

  def tire_name
    "mbuilder_application_#{id}"
  end
end
