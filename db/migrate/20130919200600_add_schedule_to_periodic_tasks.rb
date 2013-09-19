class AddScheduleToPeriodicTasks < ActiveRecord::Migration
  def change
    add_column :periodic_tasks, :schedule, :text
  end
end
