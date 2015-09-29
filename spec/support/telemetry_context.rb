RSpec.shared_context 'telemetry', telemetry: true do

  let(:to) { Time.now }
  let(:from) { to - 7.days }
  let(:period) do
    period = InsteddTelemetry::Period.new
    period.beginning = from
    period.end = to
    period
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
