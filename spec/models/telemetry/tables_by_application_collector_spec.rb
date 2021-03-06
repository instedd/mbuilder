require 'spec_helper'

describe Telemetry::TablesByApplicationCollector, telemetry: true do

  it 'counts tables by application' do
    table = Tables::Local.new('test table', '1234-5', [])

    application1 = Application.make created_at: to - 1.day, tables: ([table] * 3)
    application2 = Application.make created_at: to - 5.day, tables: ([table] * 1)
    application3 = Application.make created_at: to - 11.day
    application4 = Application.make created_at: to + 1.day, tables: ([table] * 5)

    stats = Telemetry::TablesByApplicationCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(3)

    counters.should include({
      metric: 'tables_by_application',
      key: {application_id: application1.id},
      value: 3
    })

    counters.should include({
      metric: 'tables_by_application',
      key: {application_id: application2.id},
      value: 1
    })

    counters.should include({
      metric: 'tables_by_application',
      key: {application_id: application3.id},
      value: 0
    })
  end

  it 'counts applications with 0 tables' do
    application_1 = Application.make created_at: to - 5.days
    application_2 = Application.make created_at: to + 1.day

    stats = Telemetry::TablesByApplicationCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(1)

    counters.should include({
      metric: 'tables_by_application',
      key: {application_id: application_1.id},
      value: 0
    })
  end

end
