class RenameTriggersToMessageTriggers < ActiveRecord::Migration
  def change
    rename_table :triggers, :message_triggers
  end
end
