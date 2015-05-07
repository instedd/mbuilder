class ExternalTrigger < Trigger
  include Rails.application.routes.url_helpers

  belongs_to :application
  attr_accessible :actions, :name, :parameters, :auth_method, :enabled
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :application_id
  serialize :parameters
  serialize :actions

  symbolize :auth_method, :in => [:basic_auth, :auth_token, :oauth], :scopes => true, :default => :basic_auth, :scopes => :shallow

  scope :enabled, -> { where(enabled: true) }

  def ==(other)
    other.is_a?(ExternalTrigger) && name == other.name && actions == other.actions && parameters.as_json == other.parameters.as_json && auth_method == other.auth_method
  end

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

  def self.from_hash(hash)
    new name: hash["name"],
      enabled: hash["enabled"],
      auth_method: hash["auth_method"],
      actions: Action.from_list(hash["actions"]),
      parameters: hash["parameters"].map{|parameter_hash| Pills::ParameterPill.from_hash(parameter_hash)}
  end

  def as_json
    {
      name: name,
      enabled: enabled,
      parameters: parameters,
      kind: kind,
      auth_method: auth_method,
      actions: actions.map(&:as_json)
    }
  end

  def trigger_run_url
    url_for(controller: 'external_triggers', action:'run', format: :json, application_id: application_id, trigger_name: name, host: Settings.host)
  end
end
