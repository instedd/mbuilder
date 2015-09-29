require 'spec_helper'

describe Telemetry::ChannelsByKindCollector do
  let(:to) { Time.now }
  let(:from) { to - 7.days }
  let(:period) do
    period = InsteddTelemetry::Period.new
    period.beginning = from
    period.end = to
    period
  end

  it 'counts channels by kind' do
    Channel.make created_at: to - 1.day, kind: 'clickatell'
    Channel.make created_at: to - 5.days, kind: 'pop3'
    Channel.make created_at: from - 1.day, kind: 'clickatell'
    Channel.make created_at: to + 1.day, kind: 'pop3'

    stats = Telemetry::ChannelsByKindCollector.collect_stats period

    stats.should eq({
      counters: [
        {
          metric: 'channels_by_kind',
          key: {kind: 'clickatell'},
          value: 2
        },
        {
          metric: 'channels_by_kind',
          key: {kind: 'pop3'},
          value: 1
        },
      ]
    })
  end

  it 'does not count channels where kind is null' do
    Channel.make created_at: to - 1.day, kind: 'clickatell'
    Channel.make created_at: to - 5.days, kind: nil

    stats = Telemetry::ChannelsByKindCollector.collect_stats period

    stats.should eq({
      counters: [
        {
          metric: 'channels_by_kind',
          key: {kind: 'clickatell'},
          value: 1
        }
      ]
    })
  end
end
