RSpec.shared_examples "application lifespan" do |klass|
  let!(:application) { Application.make }

  it 'updates the application lifespan when created' do
    record = klass.make_unsaved application: application

    Telemetry::Lifespan.should_receive(:touch_application).with(application)

    record.save
  end

  it 'updates the application lifespan when updated' do
    record = klass.make application: application

    Telemetry::Lifespan.should_receive(:touch_application).with(application)

    record.touch
    record.save
  end

  it 'updates the application lifespan when destroyed' do
    record = klass.make application: application

    Telemetry::Lifespan.should_receive(:touch_application).with(application)

    record.destroy
  end
end
