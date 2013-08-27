Pigeon.setup do |config|
  config.application_name = 'MBuilder'

  config.nuntium_host = Nuntium::Config['url']
  config.nuntium_account = Nuntium::Config['account']
  config.nuntium_app = Nuntium::Config['application']
  config.nuntium_app_password = Nuntium::Config['password']

  # config.verboice_host = 'http://verboice.instedd.org'
  # config.verboice_account = 'account@example.com'
  # config.verboice_password = 'password'
  # config.verboice_default_call_flow = 'Default Call Flow'

  # If you want to support Nuntium Twitter channels, get your Twitter
  # consumer keys from https://dev.twitter.com/apps
  # config.twitter_consumer_key = 'CONSUMER_KEY'
  # config.twitter_consumer_secret = 'CONSUMER_SECRET'
end
