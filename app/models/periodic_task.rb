class PeriodicTask < ActiveRecord::Base
  include Rebindable

  attr_accessible :name

  belongs_to :application

  validates_presence_of :application
  validates_presence_of :name

  serialize :logic

  after_save :schedule_job, if: :logic

  def schedule_job
    schedule_job_for Time.now
  end

  def schedule_job_for scheduled_time, run_at=nil
    run_at ||= scheduled_time
    Delayed::Job.enqueue WakeUpEvent.new(self.id, scheduled_time),
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
    context
  end

  def generate_from_number
    "+1-(234)-567-8912"
  end

  def rebind_table(from_table, to_table)
    logic.actions.each do |action|
      action.rebind_table(from_table, to_table)
    end
  end

  def rebind_field(from_field, to_table, to_field)
    logic.actions.each do |action|
      action.rebind_field(from_field, to_table, to_field)
    end
  end
end
