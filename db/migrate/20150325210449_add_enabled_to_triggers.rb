class AddEnabledToTriggers < ActiveRecord::Migration
  def change
    add_column :message_triggers,   :enabled, :boolean, default: true
    add_column :periodic_tasks,     :enabled, :boolean, default: true
    add_column :external_triggers,  :enabled, :boolean, default: true
  end
end
