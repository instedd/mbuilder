class ExternalTrigger < Trigger
  belongs_to :application
  attr_accessible :actions, :name, :parameters
  validates_uniqueness_of :name, scope: :application_id
  serialize :parameters
  serialize :actions

  symbolize :auth_method, :in => [:basic_auth, :auth_token, :oauth], :scopes => true, :default => :basic_auth, :scopes => :shallow

  # def route
  #   name + (parameters.map {|parameter| "#{parameter.name}=#{parameter.name}" }.join '&')
  # end
end
