class FlattenTriggersLogic < ActiveRecord::Migration
  def change
    remove_column :message_triggers, :pattern
    remove_column :message_triggers, :logic
    add_column :message_triggers, :message, :text
    add_column :message_triggers, :actions, :text

    rename_column :periodic_tasks, :logic, :actions

    add_column :validation_triggers, :from, :string
    add_column :validation_triggers, :invalid_value, :string
    add_column :validation_triggers, :actions, :text
    remove_column :validation_triggers, :logic
  end
end
