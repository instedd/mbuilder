require 'spec_helper'

describe Telemetry::RowsByTableCollector, telemetry: true do

  it 'counts rows by table' do
    field1 = TableFields::Local.new('a', SecureRandom.uuid, nil)
    table1 = Tables::Local.new('local table 1', SecureRandom.uuid, [field1])

    field2 = TableFields::Local.new('b', SecureRandom.uuid, nil)
    table2 = Tables::Local.new('local table 2', SecureRandom.uuid, [field2])

    field3 = TableFields::Local.new('c', SecureRandom.uuid, nil)
    table3 = Tables::Local.new('local table 3', SecureRandom.uuid, [field3])

    field4 = TableFields::Local.new('d', SecureRandom.uuid, nil)
    table4 = Tables::Local.new('local table 4', SecureRandom.uuid, [field4])

    field5 = TableFields::Local.new('e', SecureRandom.uuid, nil)
    table5 = Tables::Local.new('local table 5', SecureRandom.uuid, [field5])

    app1 = Application.make created_at: to - 1.day, tables: [table1, table2]
    app2 = Application.make created_at: to - 5.days, tables: [table3, table4]
    app3 = Application.make created_at: to + 1.day, tables: [table5]

    elastic_record = app1.elastic_record_for table1
    7.times { elastic_record.new(a: 1).save!}

    elastic_record = app1.elastic_record_for table2
    11.times { elastic_record.new(b: 1).save!}

    elastic_record = app2.elastic_record_for table3
    3.times { elastic_record.new(c: 1).save!}

    elastic_record = app3.elastic_record_for table5
    5.times { elastic_record.new(e: 1).save!}

    stats = Telemetry::RowsByTableCollector.collect_stats period
    counters = stats[:counters]

    counters.size.should eq(4)

    counters.should include({
      metric: 'rows_by_table',
      key: {table_guid: table1.guid},
      value: 7
    })

    counters.should include({
      metric: 'rows_by_table',
      key: {table_guid: table2.guid},
      value: 11
    })

    counters.should include({
      metric: 'rows_by_table',
      key: {table_guid: table3.guid},
      value: 3
    })

    counters.should include({
      metric: 'rows_by_table',
      key: {table_guid: table4.guid},
      value: 0
    })
  end

end
