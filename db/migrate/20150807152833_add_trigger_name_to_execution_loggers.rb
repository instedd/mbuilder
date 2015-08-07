class AddTriggerNameToExecutionLoggers < ActiveRecord::Migration
  def change
    add_column :execution_loggers, :trigger_name, :string
  end
end
