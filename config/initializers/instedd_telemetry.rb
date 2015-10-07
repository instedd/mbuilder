InsteddTelemetry.setup do |config|

  # Load settings from yml
  config_path = File.join(Rails.root, 'config', 'telemetry.yml')
  custom_config = File.exists?(config_path) ? YAML.load_file(config_path) : nil

  if custom_config.present?
    custom_config.each do |k,v|
      config.send("#{k}=", v)
    end
  end

  # Add custom collectors to Telemetry
  config.add_collector Telemetry::ApplicationCountCollector
  config.add_collector Telemetry::ChannelsByKindCollector
  config.add_collector Telemetry::TriggersByTypeCollector
  config.add_collector Telemetry::TablesByApplicationCollector
  config.add_collector Telemetry::ColumnsByTableCollector
  config.add_collector Telemetry::NumbersByApplicationAndCountryCollector
  config.add_collector Telemetry::RowsByTableCollector
end
