require 'spec_helper'

describe Telemetry::ColumnsByTableCollector, telemetry: true do

  it 'counts columns by table' do
    field1 = TableFields::Local.new('1', SecureRandom.uuid, [])
    field2 = TableFields::Local.new('2', SecureRandom.uuid, [])
    table1 = Tables::Local.new('local table', SecureRandom.uuid, [field1, field2])

    field3 = TableFields::ResourceMap.new('3', SecureRandom.uuid, [], nil, nil, nil, nil)
    table2 = Tables::ResourceMap.new('resourcemap table', SecureRandom.uuid, [field3], 7)

    field4 = TableFields::Local.new('4', SecureRandom.uuid, [])
    field5 = TableFields::Local.new('5', SecureRandom.uuid, [])
    field6 = TableFields::Local.new('6', SecureRandom.uuid, [])
    table3 = Tables::Local.new('local table 2', SecureRandom.uuid, [field4, field5, field6])

    field7 = TableFields::Local.new('7', SecureRandom.uuid, [])
    table4 = Tables::Local.new('table outside period', SecureRandom.uuid, [field7])

    Application.make created_at: to - 1.day, tables: [table1, table2]
    Application.make created_at: to - 5.days, tables: [table3]
    Application.make created_at: to + 1.day, tables: [table4]

    stats = Telemetry::ColumnsByTableCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(3)

    counters.should include({
      metric: 'columns_by_table',
      key: {table_guid: table1.guid},
      value: 2
    })

    counters.should include({
      metric: 'columns_by_table',
      key: {table_guid: table2.guid},
      value: 1
    })

    counters.should include({
      metric: 'columns_by_table',
      key: {table_guid: table3.guid},
      value: 3
    })
  end

end
