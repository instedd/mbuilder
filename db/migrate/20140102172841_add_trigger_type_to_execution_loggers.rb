class AddTriggerTypeToExecutionLoggers < ActiveRecord::Migration
  def change
    add_column :execution_loggers, :trigger_type, :string
  end
end
