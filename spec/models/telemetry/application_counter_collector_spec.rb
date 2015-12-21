require 'spec_helper'

describe Telemetry::ApplicationCountCollector, telemetry: true do

  it 'counts applications' do
    Application.make created_at: to - 1.day
    Application.make created_at: to - 5.days
    Application.make created_at: from - 1.day
    Application.make created_at: to + 1.day

    stats = Telemetry::ApplicationCountCollector.collect_stats period

    stats.should eq({
      counters: [{
        metric: 'applications',
        key: {},
        value: 3
      }]
    })
  end
  
end
