module Telemetry::TablesByApplicationCollector
  def self.collect_stats(period)
    tables_by_application = {}

    Application.where('created_at < ?', period.end).find_each do |application|
      count = application.tables.present? ? application.tables.count : 0
      tables_by_application[application.id] = count
    end

    counters = tables_by_application.map do |application_id, count|
      {
        metric: 'tables_by_application',
        key: {application_id: application_id},
        value: count
      }
    end

    {counters: counters}
  end
end
