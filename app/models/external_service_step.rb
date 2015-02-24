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
      guid: guid,
      variables: variables,
      type: response_type,
      response_variables: response_variables
    }
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
