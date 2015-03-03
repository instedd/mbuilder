class ExternalServiceStep < ActiveRecord::Base
  belongs_to :external_service

  serialize :variables, Array
  serialize :response_variables, Array

  validates :name, presence: true, uniqueness: { scope: :external_service_id }
  validates :guid, presence: true, uniqueness: { scope: :external_service_id }
  validate :validate_variables

  after_initialize do
    self.guid ||= Guid.new.to_s
  end

  def absolute_callback_url
    external_service.to_absolute_url callback_url
  end

  def as_json
    {
      name: name,
      display_name: display_name,
      icon: icon,
      guid: guid,
      variables: variables,
      type: response_type,
      response_variables: response_variables
    }
  end

  def export
    {
      name: name,
      display_name: display_name,
      icon: icon,
      callback_url: callback_url,
      guid: guid,
      variables: variables,
      response_type: response_type,
      response_variables: response_variables
    }
  end

  def self.import(hash)
    step = new
    step.name = hash['name']
    step.display_name = hash['display_name']
    step.icon = hash['icon']
    step.callback_url = hash['callback_url']
    step.guid = hash['guid']
    step.response_type = hash['response_type']
    step.variables = (hash['variables'] || []).map {|v| Variable.new v['name'], v['display_name']}
    step.response_variables = (hash['response_variables'] || []).map {|v| Variable.new v['name'], v['display_name']}
    step
  end

  def interpolate text, params = {}
    globals = Hash[external_service.global_variables.map do |global|
      [global.name, global.value]
    end]
    params = globals.merge params
    text.gsub /{\w+}/ do |key|
      params[key[1..-2]]
    end
  end

  class Variable < Struct.new(:name, :display_name)
    def valid?(parent, field)
      unless self.name =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/
        parent.errors.add(field, "contain invalid name #{self.name}")
      end
    end
  end

private

  def validate_variables
    variables.each{|v| v.valid?(self, :variables)}
    true
  end
end
