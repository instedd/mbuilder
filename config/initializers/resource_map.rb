module ResourceMap::Config
  Data = YAML.load_file "#{Rails.root}/config/resource_map.yml"

  def self.url
    Data["url"]
  end

  def self.use_https
    Data["use_https"]
  end
end
