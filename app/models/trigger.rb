class Trigger < ActiveRecord::Base
  include Rebindable
  include Hasheable

  self.abstract_class = true

  def rebind_table(from_table, to_table)
    actions.each do |action|
      action.rebind_table(from_table, to_table)
    end
  end

  def rebind_field(from_field, to_table, to_field)
    actions.each do |action|
      action.rebind_field(from_field, to_table, to_field)
    end
  end

  def execute(context)
    actions.each do |action|
      action.execute(context)
    end
    report_execution
  end

  def report_execution
    InsteddTelemetry.counter_add 'trigger_execution', {type: self.class.type_name}, 1
    Telemetry::Lifespan.touch_application(self.application)
  end

  def self.type_name
    @name ||= self.name.downcase.gsub(/trigger/, '')
  end
end
