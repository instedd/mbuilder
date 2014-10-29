class ExternalTrigger < Trigger
  include Rails.application.routes.url_helpers

  belongs_to :application
  attr_accessible :actions, :name, :parameters
  validates_uniqueness_of :name, scope: :application_id
  serialize :parameters
  serialize :actions

  symbolize :auth_method, :in => [:basic_auth, :auth_token, :oauth], :scopes => true, :default => :basic_auth, :scopes => :shallow

  def api_action_description(host)
    description = {
      action: "#{application.name} - #{name}",
      method: "POST",
      url: trigger_run_url(host),
    }

    description[:parameters] = (parameters || []).map do |param|
      {name: param.name, type: "string"}
    end

    description
  end

  def trigger_run_url(host)
    url_for(controller: 'external_triggers', action:'run', format: :json, application_id: application_id, trigger_name: name, host: host)
  end

  # def route
  #   name + (parameters.map {|parameter| "#{parameter.name}=#{parameter.name}" }.join '&')
  # end
end
