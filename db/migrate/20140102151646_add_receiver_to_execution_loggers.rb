class AddReceiverToExecutionLoggers < ActiveRecord::Migration
  def change
    add_column :execution_loggers, :receiver, :string
  end
end
