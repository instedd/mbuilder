class FixMessageColumnNamesInExecutionLoggers < ActiveRecord::Migration
  def change
    rename_column :execution_loggers, :receiver, :message_to
    rename_column :execution_loggers, :sender, :message_from
    rename_column :execution_loggers, :message, :message_body
  end
end
