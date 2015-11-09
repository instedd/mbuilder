module Telemetry::TriggersByTypeCollector
  def self.collect_stats(period)
    period_end = ActiveRecord::Base.sanitize(period.end)

    message_triggers_by_application = self.count_triggers_for_type('message_triggers', period_end)
    message_triggers_counters = self.to_counter(message_triggers_by_application, 'message')

    external_triggers_by_application = self.count_triggers_for_type('external_triggers', period_end)
    external_triggers_counters = self.to_counter(external_triggers_by_application, 'external')

    periodic_triggers_by_application = self.count_triggers_for_type('periodic_tasks', period_end)
    periodic_triggers_counters = self.to_counter(periodic_triggers_by_application, 'periodic')

    all_counters = message_triggers_counters.concat(external_triggers_counters).concat(periodic_triggers_counters)

    {counters: all_counters}
  end

  private

  def self.count_triggers_for_type(type, period_end)
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT applications.id, COUNT(#{type}.application_id)
      FROM applications
      LEFT JOIN #{type} ON #{type}.application_id = applications.id
      AND #{type}.created_at < #{period_end}
      WHERE applications.created_at < #{period_end}
      GROUP BY applications.id
    SQL
  end

  def self.to_counter(group, type)
    group.map do |application_id, count|
      {
        metric: 'triggers_by_application_by_type',
        key: {type: type, application_id: application_id},
        value: count
      }
    end
  end
end
