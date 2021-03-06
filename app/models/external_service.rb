class ExternalService < ActiveRecord::Base
  belongs_to :application
  has_many :external_service_steps, dependent: :destroy, autosave: true

  attr_accessible :url, :base_url, :global_variables_attributes

  serialize :global_settings, Hash

  validates :guid, presence: true, uniqueness: { scope: :application_id }
  validates :url, presence: true
  validate do
    return if url.blank?
    begin
      Net::HTTP.get(URI(add_http_if_missing(url)))
    rescue
      errors.add(:url, "can't get url")
    end
  end

  after_initialize do
    self.guid ||= Guid.new.to_s
  end

  before_create do
    # fill a base url with the url used to download the manifest
    self.url = add_http_if_missing(self.url)
    uri = URI.parse(self.url)
    self.base_url = "#{uri.scheme}://#{uri.host}#{':' + uri.port.to_s if uri.port != uri.default_port}" unless self.base_url
  end

  after_save :touch_application_lifespan
  after_destroy :touch_application_lifespan

  def update_manifest!
    response = RestClient.get self.url
    self.data = response.to_str
    self.update_from_manifest!(self.data)
  end

  def update_from_manifest!(data)
    ExternalServiceParser.new(self).parse(data).save
  end

  def global_variables_attributes=(attributes)
    attributes.each do |index, attrs|
      variable = global_variables.detect{|v| v.name == attrs[:name]}
      variable.value = attrs[:value] if variable
    end
  end

  def global_variables
    global_settings[:variables] ||= []
  end

  def global_variables=(vars)
    global_settings[:variables] = vars
  end

  def to_absolute_url(url)
    # can't use URI.parse since url may be http://{domain}/path
    if url.match(/(http|https):\/\//)
      url
    else
      base = base_url
      base.chop! if base[-1] == '/'
      url = url[1..-1] if url[0] == '/'
      "#{base}/#{url}"
    end
  end

  def as_json
    {
      name: name,
      guid: guid,
      steps: external_service_steps.map(&:as_json)
    }
  end

  def export
    {
      name: name,
      guid: guid,
      url: url,
      base_url: base_url,
      global_variables: global_variables,
      steps: external_service_steps.map(&:export)
    }
  end

  def self.from_list(list)
    return nil if list == nil
    list.map do |hash|
      import hash
    end
  end

  def self.import(hash)
    external_service = new url: hash['url'], base_url: hash['base_url']
    external_service.name = hash['name']
    external_service.guid = hash['guid']
    external_service.global_variables = (hash['global_variables'] || []).map {|v| GlobalVariable.new v}
    external_service.external_service_steps = (hash['steps'] || []).map {|s| ExternalServiceStep.import s}
    external_service
  end

  class GlobalVariable
    attr_accessor :name, :display_name, :value

    def initialize(opts = {})
      @name = opts[:name]
      @display_name = opts[:display_name]
      @value = opts[:value]
    end

    def persisted?
      false
    end
  end

  private

  def add_http_if_missing(url)
    if url.match(/^(http|https):\/\//)
      url
    else
      "http://#{url}"
    end
  end
end
