class PeriodicTask < Trigger
  attr_accessible :name, :actions, :schedule

  belongs_to :application

  validates_presence_of :application, :name, :schedule

  serialize :actions
  serialize :schedule

  after_save :schedule_job
  before_update :remove_existing_jobs

  after_initialize :set_default_schedule

  after_destroy :remove_existing_jobs

  def ==(other)
    other.is_a?(PeriodicTask) && name == other.name && actions == other.actions && schedule.as_json == other.schedule.as_json
  end

  def self.from_hash(hash)
    hash['schedule']['start_date'] = Time.parse hash['schedule']['start_date']
    schedule = IceCube::Schedule.from_hash(hash['schedule'])

    new name: hash["name"], actions: Action.from_list(hash["actions"]), schedule: schedule
  end

  def as_json
    {
      name: name,
      kind: kind,
      actions: actions.map(&:as_json),
      schedule: schedule.as_json
    }
  end

  def remove_existing_jobs
    Delayed::Job.where(:task_id => self.id).delete_all
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

  def execute_at scheduled_time
    context = DatabaseExecutionContext.new(application, PeriodicTaskPlaceholderSolver.new(Time.now), ExecutionLogger.new(application: application, trigger: self))
    context.execute self
    schedule_job_for schedule.next_occurrence scheduled_time
    if context.messages.present?
      nuntium = Pigeon::Nuntium.from_config
      nuntium.send_ao context.messages
    end
    context
  end

  def default_schedule
    s = IceCube::Schedule.new
    s.add_recurrence_rule IceCube::Rule.weekly.day(:monday, :wednesday, :friday)
    s
  end

  def rule
    schedule.recurrence_rules.first
  end

  def update_schedule_with(rule, time)
    s = IceCube::Schedule.new(time)
    s.add_recurrence_rule rule
    self.schedule = s
  end

  private

  def set_default_schedule
    if new_record? && !self.schedule
      self.schedule = default_schedule
    end
  end
end
