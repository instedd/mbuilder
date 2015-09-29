module Telemetry::ApplicationCountCollector
  def self.collect_stats(period)
    applications = Application.where('created_at < ?', period.end).count

    {
      counters: [
        {
          metric: 'applications',
          key: {},
          value: applications
        }
      ]
    }
  end
end
