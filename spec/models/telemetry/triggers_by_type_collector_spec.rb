require 'spec_helper'

describe Telemetry::TriggersByTypeCollector, telemetry: true do

  it 'counts triggers by type and application' do
    application1 = Application.make created_at: to - 250.days
    application2 = Application.make created_at: to - 200.days

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

    counters.size.should eq(6)

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
      key: {type: 'periodic', application_id: application1.id},
      value: 0
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

  it 'counts applications with 0 triggers' do
    application_1 = Application.make created_at: to - 5.days
    application_2 = Application.make created_at: to - 1.day
    application_3 = Application.make created_at: to + 1.day

    MessageTrigger.make application: application_2, created_at: to + 1.day
    ExternalTrigger.make application: application_2, created_at: to + 1.day
    create_periodic_task_for application_2, created_at: to + 1.day

    MessageTrigger.make application: application_3, created_at: to + 3.days
    ExternalTrigger.make application: application_3, created_at: to + 3.days
    create_periodic_task_for application_3, created_at: to + 3.days

    stats = Telemetry::TriggersByTypeCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(6)

    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'message', application_id: application_1.id},
      value: 0
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'message', application_id: application_2.id},
      value: 0
    })

    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'external', application_id: application_1.id},
      value: 0
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'external', application_id: application_2.id},
      value: 0
    })

    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'periodic', application_id: application_1.id},
      value: 0
    })
    counters.should include({
      metric: 'triggers_by_application_by_type',
      key: {type: 'periodic', application_id: application_2.id},
      value: 0
    })
  end

end
