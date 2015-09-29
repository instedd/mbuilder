InsteddTelemetry.setup do |config|
  # Telemetry server URL
  # config.server_url = "http://telemetry.instedd.org"

  # Telemetry remote API port
  # config.api_port = 8089

  # Add custom collectors to Telemetry
  config.add_collector Telemetry::ApplicationCountCollector
  config.add_collector Telemetry::ChannelsByKindCollector
  config.add_collector Telemetry::TriggersByTypeCollector
  config.add_collector Telemetry::TablesByApplicationCollector
end
