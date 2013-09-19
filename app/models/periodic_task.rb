class PeriodicTask < ActiveRecord::Base
  include Rebindable

  attr_accessible :name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name

  serialize :logic
  serialize :schedule

  after_save :schedule_job, if: :logic

  before_update :remove_existing_jobs

  after_initialize :set_default_schedule

  def remove_existing_jobs
    Delayed::Job.where(:task_id => self.id).first.delete
  end

  def schedule_job
    schedule_job_for schedule.next_occurrence Time.now
  end

  def schedule_job_for scheduled_time, run_at=nil
    run_at ||= scheduled_time
    Delayed::Job.enqueue WakeUpEvent.new(self.id, scheduled_time),
      :task_id => self.id,
      :run_at => run_at
  end

  def execute(context)
    logic.actions.each do |action|
      action.execute(context)
    end
  end

  def execute_at scheduled_time
    context = TireExecutionContext.new(application, NullPlaceholderSolver.new)
    execute context
    schedule_job_for schedule.next_occurrence scheduled_time
    context
  end

  def default_schedule
    s = IceCube::Schedule.new
    s.add_recurrence_rule IceCube::Rule.weekly.day(:monday, :tuesday)
    s
  end

  def rule
    schedule.recurrence_rules.first
  end

  def rule=rule
    s = IceCube::Schedule.new
    s.add_recurrence_rule rule
    self.schedule = s
  end

  def rebind_table(from_table, to_table)
    logic.rebind_table from_table, to_table
  end

  def rebind_field(from_field, to_table, to_field)
    logic.rebind_field from_field, to_table, to_field
  end

  private

  def set_default_schedule
    if new_record?
      self.schedule = default_schedule
    end
  end
end
