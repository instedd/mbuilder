class Guisso
  Config = YAML.load_file("#{Rails.root}/config/guisso.yml")

  def self.enabled?
    Config["enabled"]
  end

  def self.url
    Config["url"]
  end
end