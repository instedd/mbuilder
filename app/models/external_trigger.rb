class ExternalTrigger < Trigger
  include Rails.application.routes.url_helpers

  belongs_to :application
  attr_accessible :actions, :name, :parameters
  validates_uniqueness_of :name, scope: :application_id
  serialize :parameters
  serialize :actions

  symbolize :auth_method, :in => [:basic_auth, :auth_token, :oauth], :scopes => true, :default => :basic_auth, :scopes => :shallow

  def api_action_description
    description = {
      action: "#{name}",
      method: "POST",
      id: id,
      url: trigger_run_url,
    }

    description[:parameters] = (parameters || []).inject Hash.new do |params, param|
      params[param.name] = {label: param.name.to_s.titleize, type: "string"}
      params
    end

    description
  end

  def trigger_run_url
    url_for(controller: 'external_triggers', action:'run', format: :json, application_id: application_id, trigger_name: name, host: Settings.host)
  end
end
