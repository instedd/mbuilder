class WakeUpEvent < Struct.new(:task_id, :scheduled_time)
  def perform
    task = PeriodicTask.find(self.task_id)
    task.execute_at scheduled_time
  rescue ActiveRecord::RecordNotFound
    #If the record doesn't exist it's because the schedule was deleted, in which case no further messages must be sent.
  end
end
