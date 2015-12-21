require 'spec_helper'

describe Telemetry::Lifespan do

  let(:now) { Time.now }
  let(:from) { now - 1.week }

  before :each do
    Timecop.freeze(now)
  end

  after :each do
    Timecop.return
  end

  it 'updates the application and account lifespan' do
    application = Application.make created_at: from

    InsteddTelemetry.should_receive(:timespan_update).with('application_lifespan', {application_id: application.id}, application.created_at, now)

    InsteddTelemetry.should_receive(:timespan_update).with('account_lifespan', {account_id: application.user.id}, application.user.created_at, now)

    Telemetry::Lifespan.touch_application application
  end

  it 'updates the account lifespan' do
    user = User.make created_at: from

    InsteddTelemetry.should_receive(:timespan_update).with('account_lifespan', {account_id: user.id}, user.created_at, now)

    Telemetry::Lifespan.touch_user user
  end
end
