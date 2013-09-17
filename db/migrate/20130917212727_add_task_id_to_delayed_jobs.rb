class AddTaskIdToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :task_id, :integer
  end
end
