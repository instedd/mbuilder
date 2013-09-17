require "spec_helper"

describe "PeriodicTask" do

  before (:all) { Timecop.freeze }
  after (:all) { Timecop.return }
  let(:application) { new_application "Users: Phone, Name" }

  it "should create delayed job when saved" do
    add_data "users", [
      {"phone" => "1234", "name" => "Peter"}
    ]

    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Time.zone.now.should be_near_of(wake_up_event.scheduled_time)
    Time.zone.now.should be_near_of(job.run_at)
    context = wake_up_event.perform

    context.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter at 1234"}])
  end
end
