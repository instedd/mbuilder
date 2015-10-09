class Telemetry::RowsByTableCollector
  def self.collect_stats(period)
    rows_by_table = {}

    Application.where('created_at < ?', period.end).find_each do |application|
      application.local_tables.each do |table|
        begin
          elastic_record = application.elastic_record_for(table)
          rows_by_table[table.guid] = elastic_record.count
        rescue
        end
      end
    end

    counters = rows_by_table.map do |guid, count|
      {
        metric: 'rows_by_table',
        key: {table_guid: guid},
        value: count
      }
    end

    {counters: counters}
  end
end
