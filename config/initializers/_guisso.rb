class Guisso
  Config = YAML.load_file("#{Rails.root}/config/guisso.yml")

  def self.enabled?
    Config["enabled"]
  end

  def self.openid_url
    Config["openid_url"]
  end

  def self.sign_out_url
    Config["sign_out_url"]
  end
end