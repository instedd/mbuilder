module Telemetry::ColumnsByTableCollector
  def self.collect_stats(period)
    columns_by_table = {}

    Application.where('created_at < ?', period.end).find_each do |application|
      if application.tables.present?
        application.tables.each do |table|
          columns_by_table[table.guid] = table.fields.count
        end
      end
    end

    counters = columns_by_table.map do |guid, count|
      {
        metric: 'columns_by_table',
        key: {table_guid: guid},
        value: count
      }
    end

    {counters: counters}
  end
end
