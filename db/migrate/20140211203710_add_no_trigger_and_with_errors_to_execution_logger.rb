class AddNoTriggerAndWithErrorsToExecutionLogger < ActiveRecord::Migration
  def change
    add_column :execution_loggers, :no_trigger, :boolean
    add_column :execution_loggers, :with_errors, :boolean
  end
end
