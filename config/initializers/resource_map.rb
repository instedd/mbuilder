module ResourceMap::Config
  Data = Settings.resourcemap

  def self.url
    Data["url"]
  end

  def self.use_https
    Data["use_https"]
  end
end
