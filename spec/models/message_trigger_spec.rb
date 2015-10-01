require "spec_helper"

describe MessageTrigger do
  let(:trigger) { MessageTrigger.make actions: [] }
  let(:context) { nil }

  it 'reports execution to telemetry' do
    InsteddTelemetry.should_receive(:counter_add).with('trigger_execution', {type: 'message'}, 1)

    trigger.execute(context)
  end

end
