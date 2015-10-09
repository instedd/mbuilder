InsteddTelemetry.setup do |config|

  # Load settings from yml
  custom_config = Rails.configuration.telemetry_configuration rescue {}

  conf.server_url           = custom_config[:server_url]                   if custom_config.include? :server_url
  conf.period_size          = custom_config[:period_size_days].days        if custom_config.include? :period_size_days
  conf.process_run_interval = custom_config[:run_interval_minutes].minutes if custom_config.include? :run_interval_minutes

  # Add custom collectors to Telemetry
  config.add_collector Telemetry::ApplicationCountCollector
  config.add_collector Telemetry::ChannelsByKindCollector
  config.add_collector Telemetry::TriggersByTypeCollector
  config.add_collector Telemetry::TablesByApplicationCollector
  config.add_collector Telemetry::ColumnsByTableCollector
  config.add_collector Telemetry::NumbersByApplicationAndCountryCollector
  config.add_collector Telemetry::RowsByTableCollector
end
