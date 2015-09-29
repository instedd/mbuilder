module Telemetry::TriggersByTypeCollector
  def self.collect_stats(period)
    message_triggers_by_application = MessageTrigger.where('created_at < ?', period.end).group(:application_id).count
    message_triggers_counters = self.to_counter(message_triggers_by_application, 'message')

    external_triggers_by_application = ExternalTrigger.where('created_at < ?', period.end).group(:application_id).count
    external_triggers_counters = self.to_counter(external_triggers_by_application, 'external')

    periodic_triggers_by_application = PeriodicTask.where('created_at < ?', period.end).group(:application_id).count
    periodic_triggers_counters = self.to_counter(periodic_triggers_by_application, 'periodic')

    all_counters = message_triggers_counters.concat(external_triggers_counters).concat(periodic_triggers_counters)

    {counters: all_counters}
  end

  private

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
