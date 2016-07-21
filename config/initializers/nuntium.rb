class Nuntium
  Config = Settings.nuntium

  def self.new_from_config
    Nuntium.new Config['url'], Config['account'], Config['application'], Config['password']
  end
end
