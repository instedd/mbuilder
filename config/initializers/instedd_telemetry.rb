InsteddTelemetry.setup do |config|

  # Load settings from yml
  custom_config = Settings.telemetry

  if custom_config.present?
    if server_url = custom_config[:server_url]
      config.server_url = server_url
    end

    if period_size_hours = custom_config[:period_size_hours]
      config.period_size = period_size_hours.hours
    end

    if run_interval_minutes = custom_config[:run_interval_minutes]
      config.process_run_interval = run_interval_minutes.minutes
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
