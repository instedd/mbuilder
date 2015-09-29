require 'spec_helper'

describe Telemetry::TriggersByTypeCollector do
  let(:to) { Time.now }
  let(:from) { to - 7.days }
  let(:period) do
    period = InsteddTelemetry::Period.new
    period.beginning = from
    period.end = to
    period
  end

  it 'counts triggers by type and application' do
    application1 = Application.make
    application2 = Application.make

    # 2 message and 1 external for app1
    MessageTrigger.make application: application1, created_at: to - 1.day
    MessageTrigger.make application: application1, created_at: to - 5.days
    ExternalTrigger.make application: application1, created_at: to - 180.days
    ExternalTrigger.make application: application1, created_at: to + 1.days

    # 1 message, 2 external and 3 periodic for app2
    MessageTrigger.make application: application2, created_at: to - 1.day
    ExternalTrigger.make application: application2, created_at: to - 180.days
    ExternalTrigger.make application: application2, created_at: to - 5.days
    ExternalTrigger.make application: application2, created_at: to + 1.days
    ExternalTrigger.make application: application2, created_at: to + 10.days
    create_periodic_task_for application2, created_at: to - 1.day
    create_periodic_task_for application2, created_at: to - 7.days
    create_periodic_task_for application2, created_at: to - 17.days
    create_periodic_task_for application2, created_at: to + 20.days

    stats = Telemetry::TriggersByTypeCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(5)

    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'message', application_id: application1.id},
      value: 2
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'external', application_id: application1.id},
      value: 1
    })

    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'message', application_id: application2.id},
      value: 1
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'external', application_id: application2.id},
      value: 2
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'periodic', application_id: application2.id},
      value: 3
    })
  end

  def create_periodic_task_for(application, attrs = {})
    periodic_task = application.periodic_tasks.build
    periodic_task.name = Faker::Name.name
    attrs.each do |k, v|
      periodic_task.send("#{k}=", v)
    end
    periodic_task.save!
  end
end
