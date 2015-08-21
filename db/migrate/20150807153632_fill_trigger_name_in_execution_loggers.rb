class FillTriggerNameInExecutionLoggers < ActiveRecord::Migration
  def up
    execute %(UPDATE execution_loggers
    SET trigger_name = (
      SELECT triggers.name
      FROM message_triggers triggers
      WHERE triggers.id = execution_loggers.trigger_id)
    WHERE trigger_type = 'MessageTrigger')

    execute %(UPDATE execution_loggers
    SET trigger_name = (
      SELECT triggers.name
      FROM periodic_tasks triggers
      WHERE triggers.id = execution_loggers.trigger_id)
    WHERE trigger_type = 'PeriodicTask')

    execute %(UPDATE execution_loggers
    SET trigger_name = (
      SELECT triggers.name
      FROM external_triggers triggers
      WHERE triggers.id = execution_loggers.trigger_id)
    WHERE trigger_type = 'ExternalTrigger')
  end

  def down
  end
end
